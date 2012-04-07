package Graphics.Characters
{
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	
	import Data.Global;
	
	import Graphics.FX.LightingEngine.LE;
	import Graphics.Levels.GameLevel;
	import Graphics.Scenes.LevelScene;
	
	import Physics.PhysicsActor;
	
	import System.GameManager;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.setInterval;

	public class Actor extends Sprite
	{	
		public static const FRAME_RENDERED : String = "frameRendered";
		
		private var spritesheetPath : String = "";
		private var spritesheet : BitmapData;
		private var sheetWidth : uint = 10;
		private var sheetHeight : uint = 10;
		private var frameWidth : uint;
		private var frameHeight:  uint;
		
		public var states :Array = new Array();
		private var _currentState : String;
		public var currentFrame : uint = 0;
		public var animationSpeed : Number = 120;
		public var facingRight : Boolean = false;
		public var canJump : Boolean = false; 
 		
		public var speedx : Number = 0;
		public var speedy : Number = 0;
		public var falling : Boolean;
		public var jumping : Boolean;
		public var jumpHeight : Number = 2;
		private var jumpCount : Number = 0;
		
		public var physicsActor : PhysicsActor;
		public var isColliding : Boolean = false;
				
		public function get currentState():String { return _currentState; }
		public function set currentState(value:String): void {
			if(_currentState == value) return;
			_currentState = value;
			currentFrame = 0;
		}
		
		public function Actor(sheetName : String)
		{
			var idle :State = new State("idle", 0, 0);
			states[idle.name] = idle;
			currentState = idle.name;
			var walk:State = new State("walk", 10,13);
			states[walk.name] = walk;
			var jump:State = new State("jump", 15, 15);
			states[jump.name] = jump;
			var fall:State = new State("fall", 14, 14);
			states[fall.name] = fall;
			
			spritesheetPath = sheetName;
			
			var sprites : DisplayObject = GameManager.assetManager.Asset(sheetName) as DisplayObject;
			spritesheet =  new BitmapData(sprites.width, sprites.height, true, 0x000000);
			spritesheet.draw(sprites);
			frameWidth = spritesheet.width/sheetWidth;
			frameHeight = spritesheet.height/sheetHeight;
			
			setInterval(AnimationStep, animationSpeed);
			addEventListener(Event.ENTER_FRAME, Refresh);
			
			//addEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			this.name = "ACTOR";
			
		
		}
		
		private function AddedToStage(e:Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, RemoveFromStage);
			LoadSpritesheet();
		}
		
		private function RemoveFromStage(e:Event): void {
			removeEventListener(Event.REMOVED_FROM_STAGE, RemoveFromStage);
			addEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			UnloadSpritesheet();
		}
		
		private function LoadSpritesheet() : void {
			var loader :Loader = new Loader();
			loader.load( new URLRequest(Global.charactersPath + spritesheetPath + ".png") );
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, SpritesheetLoadComplete);
		}
		
		private function UnloadSpritesheet() : void {
			spritesheet = null;
		}
		
		private function SpritesheetLoadComplete(e:Event) : void {
			//spritesheet = new BitmapData(e.currentTarget.content.width, e.currentTarget.content.height, true, 0x000000);
			spritesheet.draw(e.currentTarget.content);
			frameWidth = spritesheet.width/sheetWidth;
			frameHeight = spritesheet.height/sheetHeight;
			
			setInterval(AnimationStep, animationSpeed);
			addEventListener(Event.ENTER_FRAME, Refresh);
		}
		
		public function Refresh(e:Event): void {			
			//if (!CheckCollisions())
			//Fall();
			Update();
			Render();
		}
		
		public function AnimationStep(): void {
			var currentAnimationSize : Number = states[currentState].endFrame - states[currentState].startFrame;
			if(currentFrame < currentAnimationSize)
				currentFrame++;
			else
				currentFrame = 0;
		}
		
		public function Update(): void {
			//var max : Point = new Point(GameManager.resolutionWidth/2 + 40, GameManager.resolutionHeight/2 + 40);
			//var min : Point = new Point(GameManager.resolutionWidth/3 + 40, GameManager.resolutionHeight/3 + 40);
			var zoom : Number = 1;
			if (GameManager.level != null)
				zoom = 1/GameManager.level.zoom;
	
			var max : Point = new Point((GameManager.currentWidth*zoom)/2 + 40, (GameManager.currentHeight*zoom)/2 + 40);
			//var min : Point = new Point((GameManager.currentWidth*zoom)/3 + 40, (GameManager.currentHeight*zoom)/3 + 40);
			var min : Point = new Point(40, 40);
			
			var pos : Point = this.localToGlobal(new Point(0, 0));
			GameManager.DTrace("Pos.X / Pos.Y",pos.x, pos.y);
			GameManager.DTrace("Max.X / Max.Y",max.x, max.y);
			GameManager.DTrace("Min.X / Min.Y",min.x, min.y);
				
			var scrollx : Number = 0;
			var scrolly : Number = 0;

			if(physicsActor != null){
				if ( (pos.x > max.x && speedx > 0) || (pos.x < min.x && speedx < 0) ) {
					scrollx = -physicsActor.body.m_linearVelocity.x;
				}
		
				if( (pos.y > max.y && physicsActor.body.m_linearVelocity.y > 0) || (pos.y < min.y && physicsActor.body.m_linearVelocity.y < 0) ){
					scrolly = -physicsActor.body.m_linearVelocity.y;
				}
			}
			
			if(GameManager.scene is LevelScene)
				(GameManager.scene as LevelScene).Scroll(scrollx, scrolly);
			
			if (physicsActor == null) return;
			physicsActor.body.WakeUp();
			physicsActor.body.m_linearVelocity.x = speedx;
			
			if (physicsActor.body.m_linearVelocity.y < 0 && !isColliding) {
				currentState = "jump";
			}
			if (physicsActor.body.m_linearVelocity.y > 0 && !isColliding) {
				currentState = "fall";
			}
				
		}
		
		public function Render(): void {
			this.graphics.clear();
			
			var state : State = states[currentState];
			var frame: uint = state.startFrame + currentFrame;
			var fx:uint = frame%sheetWidth;
			var fy:uint = frame/sheetHeight;
			
			var matrix :Matrix = new Matrix();
			matrix.translate(-fx*frameWidth - frameWidth/2, -fy*frameHeight - frameHeight);
			
			this.graphics.beginBitmapFill(spritesheet, matrix);
			this.graphics.drawRect(-frameWidth/2, -frameHeight,frameWidth, frameHeight);
			this.graphics.endFill();
			this.scaleX = facingRight ? 1 : -1;
			
			dispatchEvent(new Event(FRAME_RENDERED));
		}
		
		//Actions
		public function Idle(): void {
			currentState = "idle";
			speedx = 0;
		}
		
		public function Walk(walkRight:Boolean): void {
			currentState = "walk";
			facingRight = walkRight;
			
			var direction : Number = walkRight ? 1 : -1;
			speedx = direction * (animationSpeed/8);
		}
		
		public function Climb(): void {
			this.y -= animationSpeed/6;
		}
		
		public function Jump(): void {

			if (physicsActor == null || !canJump) return;
			
			jumpCount = jumpHeight;
			jumping = true;
			
			physicsActor.body.ApplyImpulse(new b2Vec2(0, jumpHeight * -100 ), physicsActor.body.GetLocalCenter());
		}
		
	}
}
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
	import flash.utils.Dictionary;
	import flash.utils.setInterval;

	public class BaseActor extends Sprite
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
		protected var jumpCount : Number = 0;
		
		public var physicsActor : PhysicsActor;
		public var isColliding : Boolean = false;
		
		protected var registeredActions:Dictionary = new Dictionary();
		
		public function get currentState():String { return _currentState; }
		public function set currentState(value:String): void {
			if(_currentState == value) return;
			_currentState = value;
			currentFrame = 0;
		}
		
		public function BaseActor(sheetName : String)
		{
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
		
		protected function RegisterAction(name:String, callback:Function): void{
			registeredActions[name] = callback;
		}
		
		protected function RegisterState(name:String, firstFrame:int, lastFrame:int): void{
			var newstate:State = new State(name, firstFrame, lastFrame);
			states[name] = newstate;
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
			var zoom : Number = 1;
			if (GameManager.level != null)
				zoom = 1/GameManager.level.zoom;
	
			var max : Point = new Point((GameManager.currentWidth*zoom)/2 + 40, (GameManager.currentHeight*zoom)/2 + 40);
			var min : Point = new Point(40, 40);
			
			var pos : Point = this.localToGlobal(new Point(0, 0));
				
			var scrollx : Number = 0;
			var scrolly : Number = 0;

			//TODO: move this out of here
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
		
		public function PerformAction(action:String, ...args): void {
			if(registeredActions[action] != null){
				if(args.length == 0)
					registeredActions[action]();
				else registeredActions[action](args[0]);
			}
		}

	}
}
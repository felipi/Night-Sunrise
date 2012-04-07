package Graphics.Levels {
	import Actions.ActionProxy;
	
	import Assets.PlayerDepth;
	import Assets.PlayerSpawn;
	import Assets.ScrollableForeground;
	import Assets.ScrollableLayer;
	import Assets.StaticBackground;
	
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	
	import Graphics.Characters.Actor;
	import Graphics.FX.Filters.FilterCollection;
	import Graphics.FX.LightingEngine.LE;
	import Graphics.Props.IPropBase;
	import Graphics.Scenery.LandscapeBase;
	
	import Physics.Collider;
	import Physics.ContactListener;
	import Physics.PhysicsActor;
	import Physics.PhysicsObject;
	
	import System.AssetManager;
	import System.FrameRate;
	import System.GameManager;
	import System.Input.EditorInput;
	import System.Input.GameInput;
	
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	import com.felipimacedo.Clone;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Felipi
	 * 
	 * 
	 */

	public class GameLevel extends MovieClip{
		public var backLayer : Sprite = new Sprite();
		public var middleLayer : Sprite = new Sprite();
		public var frontLayer : Sprite = new Sprite();
		public var guiLayer : Sprite = new Sprite();
		public var effectsLayer : Sprite = new Sprite();
			
		private var _cameraOffsetX : Number = 0;
		private var _cameraOffsetY : Number = 0;
		public var levelWidth : Number = width;
		public var levelHeight : Number = height;
		public var zoom : Number = 1;
		
		public var assetManager : AssetManager;
		private var actor : Actor;
		
		private var props : Array;
		private var actions : Array;
		
		//BOX2D VARS
		static private var SCALE : uint = 20;
		public var world : b2World;
		private var shape:Sprite;
		private var sdef:b2PolygonDef;
		private var bdef:b2BodyDef;
		private var body:b2Body;
		private var creationQueue:Array;
		//==========
		
		//Constructor
		public function GameLevel(xml : XML, asset:AssetManager):void {
			//Assign GameManager Level
			GameManager.level = this;
			GameManager.stage.quality = StageQuality.HIGH;
			
			props = new Array();
			actions = new Array();
			
			//Add the display layers
			addChild(backLayer); //Background
			addChild(middleLayer); //Middle, where the player and interactive objects are
			addChild(frontLayer); //Foreground
			addChild(effectsLayer); //Visual Effects
			addChild(guiLayer); //GUI, HUD
			
			assetManager = asset;
			actor = GameManager.actor;
			middleLayer.addChild(actor);
			
			if ( xml.spawns.player != null) {
				actor.x = xml.spawns.player[0].@x;
				actor.y = xml.spawns.player[0].@y;
			}
			
			creationQueue = new Array();
			SetupBox2DWorld();
			
			CreateLandscapes(xml.landscapes.landscape);
			CreateColliders(xml.colliders.collider);
			CreateProps(xml.props.prop);
			CreateActions(xml.actions.action);
		
			levelWidth = xml.map_data.width.text();
			levelHeight = xml.map_data.height.text();
			
			FrameRate.Initialize(); //Used to determine physics step
			InitializeLightingEngine();
			CreateLights(xml.lights.light);
			
			addEventListener(Event.RESIZE, ResizeScreen);
			
			//ChangeZoom(-0.5)
			//setTimeout(function(){TweenZoom(0.65, 1);}, 2500);
			if(GameManager.DEBUG){
				//Allow mouse wheel zoom if debugging.
				GameManager.player.input.addEventListener(EditorInput.WHEEL, DChangeZoom);
			}
		}
		
		//SCREEN RESIZE =LISTENER
		private function ResizeScreen(e:Event):void{
			GameManager.resolutionWidth = stage.stageWidth;
			GameManager.resolutionHeight = stage.stageHeight;
		}
		
		//ZOOM FUNCTIONS
		public function TweenZoom(_target:Number, _duration:Number):void{
			Tweener.addTween(this, {zoom:_target, time:_duration, onUpdate:function(){
				backLayer.scaleX = backLayer.scaleY = zoom;
				middleLayer.scaleX = middleLayer.scaleY = zoom;
				frontLayer.scaleX = frontLayer.scaleY = zoom;
				effectsLayer.scaleX = effectsLayer.scaleY = zoom;			
				
				LE.RedrawMask();
				Scroll(0,0);
			}});
		}
		
		public function ChangeZoom(value:Number):void{
			zoom += value;
			if(zoom > 2){
				zoom = 2;
			}
			if(zoom < 0.5){
				zoom = 0.5;
			}
			
			backLayer.scaleX = backLayer.scaleY = zoom;
			middleLayer.scaleX = middleLayer.scaleY = zoom;
			frontLayer.scaleX = frontLayer.scaleY = zoom;
			effectsLayer.scaleX = effectsLayer.scaleY = zoom;			
			
			LE.RedrawMask();
		}
		
		//MOUSE WHEEL ZOOM =DEBUG
		private static function DChangeZoom(me:MouseEvent) : void {
			GameManager.DTrace("WHEEL TURN", me.delta);
			var factor : Number = me.delta;
			GameManager.level.ChangeZoom(factor/10);
		}
		
		//PHYSICS METERING CONVERSION =UTIL
		public static function FlashToBox(v:Number) : Number {
			return v / SCALE;
		}
		
		public static function BoxToFlash(v:Number) : Number {
			return v * SCALE;
		}
		
		//LIGHT ENGINE INITALIZATION =LIGHT
		private function InitializeLightingEngine() : void {
			//LE.Initialize(0xBBBBDD);
			LE.Initialize(0x555577);
			
			//LE.CreateMousePointLight(300, 100, 255, 0xFFFFDE);
			//LE.CreateDynamicPointLight(150, GameManager.level, {x:"mouseX", y:"mouseY"});
			//LE.CreateDynamicPointLight(100, actor, {x:'x', y:'y'}, 0xFF0000);
			//LE.CreateFixedPointLight(500, 600, 100, 0xAAFFAA);
			//LE.CreateFixedPointLight(200, 100, 120, 0xFFAAAA);
			//LE.CreateFixedPointLight(70, 200, 195-60, 0xFFDD99);
			//LE.CreateFixedPointLight(150, 1880, 220-60, 0xFFDD99);
			//LE.CreateFixedPointLight(70, 600, 528-60, 0xFFDD99);
			//LE.CreateFixedPointLight(70, 2200, 486-60, 0xFFDD99);
			//LE.CreateFixedPointLight(240, 1800, 160, 0xAAAAFF);
			//LE.CreateFixedPointLight(350, 800, 100, 0xFF88FF);
			
			LE.Run();
		}
		
		//PHYSICS
		private function updateWorld():void
		{
			//world.Step(1 / 20, GameManager.stage.frameRate);
			world.Step(1 / 20, FrameRate.fps);
			
			for (var b : b2Body = world.GetBodyList(); b; b = b.GetNext()) {
				if (b.GetUserData() == "dead") {
					world.DestroyBody(b);
				}
			}
			
			while (creationQueue.length > 0) {
				CreateObject(creationQueue.pop());
			}
		}
		
		private function SetupBox2DWorld():void {
			var aabb : b2AABB = new b2AABB();
			aabb.lowerBound = new b2Vec2(-6400,-4800);
			aabb.upperBound = new b2Vec2(FlashToBox(64000),FlashToBox(48000));
			
			world = new b2World(aabb, new b2Vec2(0, 10), true);
			world.SetGravity(new b2Vec2(0, 15));
			var m_contactListener : ContactListener = new ContactListener();
			world.SetContactListener(m_contactListener);

			if(GameManager.DEBUG){
				shape = new Sprite();
				middleLayer.addChild(shape);
				shape.scaleX = shape.scaleY = SCALE;
				var debug  : b2DebugDraw = new b2DebugDraw();
				debug.m_sprite = shape;
				debug.m_lineThickness = 1;
				debug.m_drawFlags = b2DebugDraw.e_jointBit | b2DebugDraw.e_shapeBit | b2DebugDraw.e_coreShapeBit;
				shape.alpha = 0.5;
				world.SetDebugDraw(debug);
			}
			
			setInterval(updateWorld, GameManager.stage.frameRate);
			
			CreateCharacter(actor);
		}
		
		//CREATORS
		private function CreateCharacter(character : Actor):void {
			bdef = new b2BodyDef();
			bdef.fixedRotation = true;
			bdef.position = new b2Vec2(FlashToBox(character.x), FlashToBox(character.y) - FlashToBox(character.height)/2);
			sdef = new b2PolygonDef();
			sdef.density = 1; 
			sdef.friction = 0;
			sdef.restitution = 0;
			sdef.SetAsBox(FlashToBox(character.width)/3, FlashToBox(character.height)/2);
			
			body = world.CreateBody(bdef);
			body.CreateShape(sdef);
			body.SetMassFromShapes();
			body.SetUserData(character);
			
			var physicsActor : PhysicsActor = new PhysicsActor(body, character);
			character.physicsActor = physicsActor;
		}
		
		private function CreateLandscapes(xml:XMLList):void
		{
			for (var i : uint = 0; i < xml.length(); i++) {
				var landscapeImage : DisplayObject = assetManager.Asset(xml[i].@asset)  as DisplayObject;
				
				var landscape : LandscapeBase = new LandscapeBase(landscapeImage, xml[i].@blur, xml[i].@horizontalScroll == "true" ? true : false , xml[i].@verticalScroll  == "true" ? true : false);
				
				if(xml[i].@layer == "back")
					backLayer.addChild( landscape );
				else
					frontLayer.addChild( landscape );	
			}
		}
		
		private function CreateLights(xml:XMLList):void
		{
			for (var i : uint = 0; i < xml.length(); i++) {
				
				var lightx : Number, lighty : Number, radius : Number;
				var lightColor : int;
				
				lightx = xml[i].@x;
				lighty = xml[i].@y;
				radius = xml[i].@radius;
				lightColor = xml[i].@color;
				
				LE.CreateFixedPointLight(radius, lightx, lighty, lightColor);
			}
		}
		
		private function CreateColliders(xml:XMLList):void
		{
			for (var i : uint = 0; i < xml.length(); i++) {
				bdef = new b2BodyDef();
				bdef.position = new b2Vec2(FlashToBox(xml[i].@x) + FlashToBox(xml[i].@width/2), FlashToBox(xml[i].@y) + FlashToBox(xml[i].@height/2));
				sdef = new b2PolygonDef();
				sdef.density = 0;
				sdef.SetAsBox(FlashToBox(xml[i].@width/2), FlashToBox(xml[i].@height/2));
				bdef.angle = xml[i].@rotation * (Math.PI/180) % 360;
				
				body = world.CreateBody(bdef);
				body.CreateShape(sdef);
				body.SetMassFromShapes();
				
				var texture : DisplayObject = assetManager.Asset(xml[i].@texture) as DisplayObject;
				var collider : Collider = new Collider();
				collider.body = body;
				
				if(texture != null){
					collider.x = xml[i].@x;
					collider.y = xml[i].@y;
					collider.Paint(texture, xml[i].@width, xml[i].@height);
				}
				
				
			}
		}
		
		private function CreateProps(xml:XMLList):void
		{
			for (var i : uint = 0; i < xml.length(); i++) {
				var Definition : Class = getDefinitionByName(xml[i].@definition) as Class;
				var prop : *  = new Definition();
				prop.addChild( assetManager.Asset(xml[i].@asset) as DisplayObject );
				//var clone : DisplayObject = new Clone(prop) as DisplayObject;
				if(xml[i].@bloom == "true"){
				/*
					if(xml[i].hasOwnProperty("@lightmap222") ){
						lightmap = GameManager.level.assetManager.Asset(xml[i].@lightmap) as DisplayObject;		
					}
				*/
					//LE.AddBloomToObject(prop);
				}
				//prop.getChildAt(0).scaleX = xml[i].@scale;
				//prop.getChildAt(0).scaleY = xml[i].@scale;
				prop.scaleX = prop.scaleY = xml[i].@scale;
				prop.getChildAt(0).x -= prop.getChildAt(0).width / 2;
				prop.getChildAt(0).y -= prop.getChildAt(0).height / 2;
				prop.x = xml[i].@x;
				prop.y = xml[i].@y;
				
				if(xml[i].@layer == "Front") frontLayer.addChild(prop);
				else middleLayer.addChild(prop);
				if (xml[i].@visible == "false") prop.visible = false;
				
				prop.Initialize(xml[i]);
				
				props.push( { key:xml[i].@name, object:prop } );
			}
		}
		
		private function CreateActions(xml:XMLList):void
		{
			for (var i : uint = 0; i < xml.length(); i++) {
				var prop:* = null;
				for each(var pr:* in props){
					if(pr["key"] == xml[i].@trigger){
						prop = pr["object"];
						break;
					} 
				}
				
				if(prop == null) continue;//trigger not found;
				
				//TODO: change to a subaction queue
				var method:String = xml[i].@callback;
				var params:Object = {};
				var xmlParams:XMLList = xml[i].param;
				
				for(var p : uint = 0; p < xmlParams.length(); p++){
					params[xmlParams[p].@name] = xmlParams[p].@value;
				}
				
				GameManager.DTrace(params["text"]);
				
				prop.addEventListener("triggered", function():void{
					ActionProxy[method](params);
				});
			}
			
		}
		
		public function CreateObject(object : DisplayObject):void {
			bdef = new b2BodyDef();
			var pos : Point = object.localToGlobal(new Point(0, 0));
			bdef.position = new b2Vec2(FlashToBox(pos.x - cameraOffsetX), FlashToBox(pos.y - cameraOffsetY));
			sdef = new b2PolygonDef();
			bdef.angle = object.rotation * (Math.PI / 180) % 360;
			
			var vertices : Array = (object as MovieClip).vertices
			var px:int = (object as MovieClip).matrixi;
			var py:int = (object as MovieClip).matrixj;
			var pw:Number = (object as MovieClip).piecew;
			var ph:Number = (object as MovieClip).pieceh;
			
			sdef.vertexCount = vertices.length;
			for (var i:int=0; i < vertices.length; i++ ){
				sdef.vertices[i].Set(FlashToBox( vertices[i].x - px*pw), FlashToBox( vertices[i].y - py*ph));
			}
			sdef.density = 1.0;
			sdef.friction = 0.3;
			sdef.restitution = 0.1;
			
			body = world.CreateBody(bdef);
			body.CreateShape(sdef);
			body.SetMassFromShapes();
			body.SetUserData(object);
			
			var physicsObject : PhysicsObject = new PhysicsObject();
			physicsObject.addChild(object);
			physicsObject.x = object.x;
			physicsObject.y = object.y;
			object.x = object.y = 0;
			//object.x -= object.width / 2;
			//object.y -= object.height / 2;
			middleLayer.addChild(physicsObject);
			physicsObject.body = body;
		}
		
		public function AddObjectToCreationQueue(object : DisplayObject) : void {
			creationQueue.push(object);
		}
		
		//CAMERA METHODS
		public function CenterToPosition(posx:Number, posy:Number): void {
			
		}
		
		public function Scroll(scrollx:Number, scrolly:Number, centering : Boolean = false):void {
			var zoomfactor:Number = (1/GameManager.level.zoom);
			_cameraOffsetX = BoxToFlash(actor.physicsActor.body.GetWorldCenter().x);
			_cameraOffsetY = BoxToFlash(actor.physicsActor.body.GetWorldCenter().y);
			//_cameraOffsetX = (GameManager.stage.stageWidth/2) - _cameraOffsetX;
			//_cameraOffsetY = (GameManager.stage.stageHeight/2) - _cameraOffsetY;
			_cameraOffsetX = (GameManager.stage.stageWidth/2*zoomfactor) - _cameraOffsetX;
			_cameraOffsetY = (GameManager.stage.stageHeight/2*zoomfactor) - _cameraOffsetY;
			
			if (_cameraOffsetX < -levelWidth + GameManager.stage.stageWidth*zoomfactor) {
				_cameraOffsetX = -levelWidth + GameManager.stage.stageWidth*zoomfactor;
			}
			
			if (_cameraOffsetX > 0) {
				_cameraOffsetX = 0;
			}
			
			if (_cameraOffsetY < -levelHeight+GameManager.stage.stageHeight*zoomfactor) {
				_cameraOffsetY = -levelHeight+GameManager.stage.stageHeight*zoomfactor;
			}
			if (_cameraOffsetY > 0) {
				_cameraOffsetY = 0;
			}

			middleLayer.x = cameraOffsetX*zoom;
			middleLayer.y = cameraOffsetY*zoom;
			frontLayer.x = cameraOffsetX*zoom;
			frontLayer.y = cameraOffsetY*zoom;
		}
		
		public function get cameraOffsetX():Number { return _cameraOffsetX; }
		
		public function get cameraOffsetY():Number { return _cameraOffsetY; }

	}
}
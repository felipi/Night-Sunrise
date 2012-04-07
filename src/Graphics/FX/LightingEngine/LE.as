package Graphics.FX.LightingEngine
{
	import Graphics.Characters.Actor;
	
	import System.FrameRate;
	import System.GameManager;
	
	import com.efnx.fps.fpsBox;
	import com.felipimacedo.Clone;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	
	public class LE
	{
		public static var instance : LE;
		public static var ambientLight : int = 0xFFFFFF;
		public static var step : Number;
		public static var originalStep : Number = 50;
		public static var highQuality : Boolean = true;
		public static var timeInterval : int = 100;
		
		private static var _bmd : BitmapData;
		private static var matrix : Matrix;
		private static var bmdVector:Vector.<uint>;
		public static function get bmd() : BitmapData { return _bmd;}
		
		public static var running : Boolean = false;
		public static var mask : Sprite;
		public static var layer : Sprite;
		public static var lights : Vector.<DSprite>;
		
		public function LE(){
			
		}
		
		public static function Initialize(ambLight : int = 0xFFFFFF) : void{
			lights = new Vector.<DSprite>();
			ambientLight = ambLight;
			matrix = new Matrix();
			
			layer = new Sprite(); layer.name = "LightLayer";
			mask = new Sprite(); mask.name = "LightLayerMask";
			
			//Setup lighting mask using ambient light;
			//layer.cacheAsBitmap = true;
			//mask.cacheAsBitmap = true;
			layer.addChild(mask);
			RedrawMask(mask);
			GameManager.level.effectsLayer.addChild(layer);
			layer.blendMode = BlendMode.MULTIPLY;
			layer.visible = false;
			//===
			step=originalStep;
			
			setInterval(Update, timeInterval);
		}
		
		public static function RedrawMask(mask:Sprite = null):void{
			if(mask == null){
				var layer:Sprite = GameManager.level.effectsLayer.getChildByName("LightLayer") as Sprite;
				mask = layer.getChildByName("LightLayerMask") as Sprite;
			}
			mask.graphics.clear();
			mask.graphics.beginFill(LE.ambientLight);
			mask.graphics.drawRect(0,0,GameManager.stage.stageWidth*(1/GameManager.level.zoom),
									   GameManager.stage.stageHeight*(1/GameManager.level.zoom));
			mask.graphics.endFill();
		}
		
		public static function ResizeScreen(e:Event):void {
			RedrawMask();
		}
		
		public static function Run() : void{
			running = true;
			layer.visible = true;
			
			GameManager.stage.addEventListener(Event.RESIZE, ResizeScreen);
		}
		
		public static function Stop() : void{
			running = false;
			layer.visible = false;
			
			GameManager.stage.removeEventListener(Event.RESIZE, ResizeScreen);
		}
		
		public static function Trigger() : void{
			//if(instance == null) return;
			
			if(running){
				if(highQuality){
					highQuality = false;
					step = (originalStep/5) / (lights.length);
				}else{
					LE.Stop();
				}
			} else {
				step = originalStep / (lights.length);
				highQuality = true;
				LE.Run();
			}
			
			trace("LE state is: ", running);
		}
		
		public static function Update() : void{
			if (!running) return;
			/*
				_bmd = new BitmapData(GameManager.stage.width, GameManager.stage.height, true, 0xFFFFFF);
				matrix.identity(); 
				matrix.translate(GameManager.level.cameraOffsetX, GameManager.level.cameraOffsetY);
				_bmd.draw(GameManager.level.middleLayer, matrix);
				
				bmdVector = _bmd.getVector(_bmd.rect);
			*/
			var numVisibleLights : int = 0;
			for each(var light : DSprite in lights){
				if(light != null){
					light.Update();
					if(LE.mask.hitTestObject(light.placeholder))
						numVisibleLights++;
				}
			}
			if(numVisibleLights > 0)
				step = originalStep / (numVisibleLights);
		}
		
		public static function AddBloomToObject(object:Sprite, animated:Boolean = false, container:DisplayObjectContainer=null) : void{
			var lightmap : Sprite = new Clone(object) as Sprite;
			var cmFilter : ColorMatrixFilter = new ColorMatrixFilter();

			var matrix:Array= new Array();
			matrix = matrix.concat([1, 0.5, 0.5, 0, -60]); // red
			matrix = matrix.concat([0.5, 1, 0.5, 0, -60]); // green
			matrix = matrix.concat([0.5, 0.5, 1, 0, -60]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			cmFilter = new ColorMatrixFilter(matrix);

			//lightmap.blendMode = BlendMode.SCREEN;
			lightmap.filters = [new BlurFilter(7,7), cmFilter];
			lightmap.x -= lightmap.width/2;
			lightmap.y -= lightmap.height/2;
			
			if(container == null){
				object.addChild(lightmap);
			}else{
				container.addChild(lightmap);
				lightmap.x = object.x;
				lightmap.y = object.y;
				lightmap.scaleX = lightmap.scaleY = 6;
			}
			
			if(animated){
				object.addEventListener(Actor.FRAME_RENDERED, function():void{
					if(container == null){
						object.removeChild(lightmap);
					}else{
						container.removeChild(lightmap);
					}
					trace("ANIMATED BLOOM:", lightmap.x, lightmap.y, lightmap.width, lightmap.height);
					AddBloomToObject(object,animated,container);
					object.removeEventListener(Actor.FRAME_RENDERED, arguments.callee);
				});
				//setTimeout(function(){ object.removeChild(lightmap); AddBloomToObject(object,animated); trace("ANIMATED BLOOM"); }, GameManager.stage.frameRate);
			}
		}
		
		public static function CreateFixedPointLight(radius:Number, posx:Number, posy:Number, color:int = 0xFFFFFF, nearAttenuation:int = 150, farAttenuation:int = 255, blur:Boolean = true) : void {
			var refObj : Object = {x:posx, y:posy};
			refObj.x = posx;
			refObj.y = posy;
			
			CreateDynamicPointLight(radius, refObj, {x:"x", y:"y"}, color, nearAttenuation, farAttenuation, blur);
		}
		
		public static function CreateDynamicPointLight(radius:Number, object:Object, position:Object, color:int = 0xFFFFFF, nearAttenuation:int = 150, farAttenuation:int = 255, blur:Boolean = true) : void {

			var plight : DSprite = new DSprite();
			//step = originalStep / (lights.length+1);
			//step = originalStep;

			if(blur) plight.filters = [new BlurFilter(4, 4, 3)];
			plight.blendMode = BlendMode.LIGHTEN;
			trace("Created Dynamic Point Light");
			
			//plight.cacheAsBitmap = true;
			var gmatrix:Matrix = new Matrix();
			gmatrix.createGradientBox(radius*2, radius*2, 0, -radius, -radius);
			
			var placeholder : Sprite = new Sprite();
			placeholder.graphics.beginFill(0xFF0000);
			placeholder.graphics.drawRect(-radius, -radius,radius*2,radius*2);
			placeholder.graphics.endFill();
			placeholder.visible = false;
			plight.addChild(placeholder);
			plight.placeholder = placeholder;
			
			var overlappingObjects : Vector.<Sprite>;
			
			//plight.addEventListener(Event.ENTER_FRAME, function(){
			plight.Update = function Update():void {
				plight.x = object[position.x] + GameManager.level.cameraOffsetX; 
				plight.y = object[position.y] + GameManager.level.cameraOffsetY;
				
				var cull :Boolean = LE.mask.hitTestObject(placeholder);
				if(!cull) return;
				
				var childi : int = 0;
				var midLayer : Sprite = GameManager.level.middleLayer;
				
				var timer : int = getTimer();
				overlappingObjects = new Vector.<Sprite>();
				for (childi; childi < midLayer.numChildren; childi++){
					var obj : Sprite = Sprite(midLayer.getChildAt(childi));
					var dx : Number = obj.x - plight.x;
					var dy : Number = obj.y - plight.y;
					var objr : Number = obj.width > obj.height ? obj.width/2 : obj.height/2;
					var rsum : Number = objr + radius;
					
					//var overlap : Boolean = dx*dx + dy*dy <= rsum*rsum;
					var overlap : Boolean = placeholder.hitTestObject(obj);
					if(overlap) {
						overlappingObjects.push(obj);
					}
				}
				
				if(overlappingObjects.length <= 0) {
					plight.graphics.clear();
					plight.graphics.beginGradientFill(GradientType.RADIAL, [color, color], [1,0], [nearAttenuation,farAttenuation], gmatrix);
					plight.graphics.drawCircle(0,0,radius);
					plight.graphics.endFill();
					return;
				}

				var offsetX:Number = plight.x - radius;
				var offsetY:Number = plight.y - radius;
			
				var mx : Number = object[position.x] + GameManager.level.cameraOffsetX; 
				var my : Number = object[position.y] + GameManager.level.cameraOffsetY;
					
				_bmd = new BitmapData(radius*2, radius*2, true, 0xFFFFFF);
				_bmd.lock();
				matrix.identity(); 
				matrix.translate(GameManager.level.cameraOffsetX - mx + radius, GameManager.level.cameraOffsetY - my + radius);
				//for each(var obj:Sprite in overlappingObjects){
				//	_bmd.draw(obj, matrix);
				//}
				_bmd.draw(GameManager.level.middleLayer,matrix);
				bmdVector = _bmd.getVector(_bmd.rect);
				_bmd.unlock();
				
				var commands:Vector.<int> = new Vector.<int>();
				var coords:Vector.<Number> = new Vector.<Number>();

				plight.graphics.clear();
				plight.graphics.beginGradientFill(GradientType.RADIAL, [color, color], [1,0], [nearAttenuation,farAttenuation], gmatrix);
				for (var i:int=0; i<=360; i+= 360/step ) {
					var ray_angle:Number = to_radians((-90+i));
					var rsin:Number = Math.sin(ray_angle);
					var rcos:Number = Math.cos(ray_angle);
					var jstep : int = radius/step;
					jstep = jstep <= 0 ? 1 : jstep;
					
					for (var j:int=1; j<=radius; j+= jstep) {
						//if( (bmd.getPixel32(offsetX+radius+j*rcos, offsetY+radius+j*rsin) >> 24 & 0xFF) > 0){
						var vi:int = 0+radius+j*rcos;
						var vj:int = 0+radius+j*rsin;
						var vp:int = vj * _bmd.width + vi;
						if( vp < 0 || vp >= bmdVector.length) break;
						if( (bmdVector[vp] >> 24 & 0xFF) > 0) {
							break;
						}
					}
					//if(i==0) plight.graphics.moveTo(j*rcos, j*rsin);
					//plight.graphics.lineTo(j*rcos, j*rsin);
					if(i==0) commands.push(1);
					else commands.push(2);
					coords.push(j*rcos,j*rsin);
				}
				plight.graphics.drawPath(commands, coords);
				plight.graphics.endFill();

			//});
			}
			
			lights.push(plight);
			layer.addChild(plight);
			//GameManager.level.addChild(plight);
		}

		public static function to_radians(n:Number):Number {
			return (n*0.0174532925);
		}
		public static function to_degrees(n:Number):Number {
			return (n*57.2957795);
		}
		
	}
}

dynamic class DSprite extends flash.display.Sprite {
	
}
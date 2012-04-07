package Graphics.FX
{
	import System.GameManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BlobBackground extends Sprite
	{
		
		var visible_bd:BitmapData;
		var invisible_bd:BitmapData;
		var bitmap:Bitmap;
		
		var rect:Rectangle;
		var color:uint;
		var point:Point = new Point(0,0);
		var multiplier:Number = 0.47;
		var num_of_blobs:Number = 2;
		var blobs:Array = new Array();
		var speeds:Array = new Array();
		
		public function BlobBackground(target_width: int, target_height: int, target_color:uint)
		{
			//graphics.beginFill(color);
			//graphics.drawRect(0, 0, target_width, target_height);
			//graphics.endFill();
			rect = new Rectangle(0, 0, target_width, target_height);
			color = target_color;
			
			visible_bd = new BitmapData(rect.width, rect.height);
			invisible_bd = new BitmapData(rect.width, rect.height);
			bitmap = new Bitmap(visible_bd);
			
			GameManager.DTrace(rect.width, rect.height);
			for(var i:int = 0; i < num_of_blobs; i++){
				var bx:Number = Math.random()*rect.width;
				var by:Number = Math.random()*rect.height;
				var new_blob:Point = new Point(bx, by);
				blobs.push(new_blob);
				
				var sx:Number = Math.random() - 0.5;
				var sy:Number = Math.random() - 0.5;
				var new_speed:Point = new Point(sx, sy);
				speeds.push(new_speed);
			}
			GameManager.DTrace(bitmap.x, bitmap.y);
			addChild(bitmap);
			
			var bevel:BevelFilter=new BevelFilter();
			bevel.blurX = bevel.blurY = 20;
			bevel.distance = 50;
			bevel.highlightColor= color + 0x444444;
			bevel.shadowColor= color - 0x222222;
			var blur:BlurFilter=new BlurFilter(5,5);
			var glow:GlowFilter=new GlowFilter(0xFFFFFF, 0.6, 30, 30, 1, 1, false, false);
			bitmap.filters = [blur, bevel];
			
			addEventListener(Event.ENTER_FRAME, Update);
			addEventListener(Event.REMOVED, Removed);
		}
		
		private function Removed(e:Event):void{
			removeEventListener(Event.ENTER_FRAME, Update);
			bitmap.filters = [];
			bitmap = null;
			visible_bd = null;
			invisible_bd = null;
		}
		
		private function Update(e:Event): void{
			for(var i:int = 0; i < num_of_blobs; i++){
				blobs[i].x += speeds[i].x;
				blobs[i].y += speeds[i].y;
			}
			invisible_bd.perlinNoise(120, 120, 2, 0, false, true, 7, true, blobs);
			visible_bd.fillRect(rect, 0xffffff);
			visible_bd.threshold(invisible_bd, rect, point, ">", multiplier*0xffffff, 0xff000000 + color, 0x00ffffff, false);
		}
	}
}
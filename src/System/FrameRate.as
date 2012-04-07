package System
{
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class FrameRate
	{
		private static var prevTime : int;
		private static var _fps : int;
		private static var tf : TextField;
		
		public static function get fps() : int{ return _fps; }
		
		public static function Initialize() : void {
			prevTime = getTimer();
			GameManager.stage.addEventListener(Event.ENTER_FRAME, getFps);
			
			var ts : TextFormat = new TextFormat("Arial, Helvetica", 24, 0xFFFFFF);
			tf = new TextField();
			tf.defaultTextFormat = ts;
			tf.filters = [new GlowFilter(0x000000,1,0,0)];
			
			if(GameManager.DEBUG)
				GameManager.level.guiLayer.addChild(tf);
			
			tf.x = 10;
			tf.y = 10;
		}
		
		private static function getFps(e:Event):void {
			var time : int = getTimer();
			var cfps : Number = 1000 / (time - prevTime);
			prevTime = getTimer();	

			_fps = cfps;
			
			tf.text = "FPS: " + _fps;
		}
	}
}
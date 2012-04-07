package System.Input
{
	import System.GameManager;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import uk.co.bigroom.input.KeyPoll;

	public class EditorInput extends ActorInput
	{
		private var key : KeyPoll;
		private var spacePressed:Boolean = false;
		
		public static const CLICK : String = "editorClick";
		public static const WHEEL : String = "editorWheel";
		
		public function EditorInput()
		{
			key = new KeyPoll(GameManager.stage);
			
			GameManager.stage.addEventListener(MouseEvent.CLICK, Click);
			
			GameManager.stage.addEventListener(MouseEvent.MOUSE_WHEEL, Wheel);
		}
		
		private function Refresh(k:Event): void {
		}
		
		private function Release(k:KeyboardEvent): void {
			
		}
		
		private function Click(me:MouseEvent) : void {
			dispatchEvent(new Event(CLICK));
		}
		
		private function Wheel(me:MouseEvent) : void {
			dispatchEvent(new MouseEvent(WHEEL,true,false,null,null,null,false,false,false,false,me.delta));	
		}
		
	}
}
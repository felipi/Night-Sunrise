package System.Input 
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import System.GameManager;
	import System.Input.GameInput;
	import uk.co.bigroom.input.KeyPoll;
	
	/**
	 * ...
	 * @author Felipi
	 */
	public class SceneInput extends GameInput
	{
		
		public static const SPACE : String = "space";
		public static const ENTER : String = "enter";
		public static const KEY_UP : String = "key_up";	
		
		private static const kRight : uint = 39;
		private static const kLeft : uint = 37;
		private static const kUp : uint = 38;
		private static const kDown : uint = 40;
		
		private var key : KeyPoll;
		
		public function SceneInput() 
		{
			key = new KeyPoll(GameManager.stage);
			
			GameManager.stage.addEventListener(KeyboardEvent.KEY_UP, Release);
			GameManager.stage.addEventListener(Event.ENTER_FRAME, Refresh);
		}
		
		private function Refresh(k:Event): void {
			if(key.isDown(Keyboard.SPACE)){
				dispatchEvent(new Event(SPACE));
			}
			if(key.isDown(Keyboard.ENTER)){
				dispatchEvent(new Event(ENTER));
			}
		}
		
		private function Release(k:KeyboardEvent): void {
			dispatchEvent(new Event(KEY_UP));
		}
	}

}
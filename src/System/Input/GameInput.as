package System.Input
{
	import flash.events.EventDispatcher;
	import flash.ui.Keyboard;
	
	public class GameInput extends EventDispatcher
	{
		
		protected static const kRight : int = 39; //right arrow
		protected static const kLeft : int = 37; //left arrow
		protected static const kUp : int = 38; //up arrow
		protected static const kDown : int = 40; //down arrow
		
		protected static const kDUp : int = 49; //1 key
		protected static const kDRight : int = 50; //2 key
		protected static const kDDown : int = 51; //3 key
		protected static const kDLeft : int = 52; //4 key
		
		protected static const kSelect : int = Keyboard.TAB; //tab
		protected static const kStart : int = Keyboard.ENTER; //enter;return
		
		protected static const kShoulderLeft : int = Keyboard.SHIFT; //shift
		protected static const kShoulderRight : int = 82; //S key
		
		protected static const kButtonA : int = Keyboard.SPACE; //space
		protected static const kButtonB : int = 67; //C key
		protected static const kButtonX : int = 88; //X key
		protected static const kButtonY : int = 90; //Z key
		
	}
	
}
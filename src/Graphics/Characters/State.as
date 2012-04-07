package Graphics.Characters
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class State extends EventDispatcher
	{
		public const ENTER : String = "STATE_ENTER";
		public var name : String;
		public var startFrame : uint;
		public var endFrame : uint;
		
		public var isAnimated:Boolean = true;
		public var animateStoped:Boolean = false;
		
		public function State(stateName:String, start:uint, end:uint)
		{
			name = stateName;
			startFrame = start;
			endFrame = end;
		}
		
		public function EnterState(): void{
			dispatchEvent(new Event(ENTER));
		}
	}
}
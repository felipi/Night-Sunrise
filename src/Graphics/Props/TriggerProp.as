package Graphics.Props
{
	import flash.events.Event;

	public class TriggerProp extends PhysicsProp implements IPropBase
	{
		public function TriggerProp()
		{
			
		}
		
		override public function Initialize(xml : XML) : void {
			super.Initialize(xml);
		}
		
		override public function Contact():void {
			super.Contact();
		
			dispatchEvent(new Event("triggered"));
		}
	}
}
package
{	
	import Graphics.HUD.HUD;
	import Graphics.Levels.GameLevel;
	import Graphics.Props.BreakableObject;
	import Graphics.Props.BreakableProp;
	import Graphics.Props.PhysicsProp;
	import Graphics.Props.SimpleProp;
	import Graphics.Props.TriggerProp;
	
	import System.GameManager;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	[SWF(width="720", height="480", frameRate="30", backgroundColor='#000000')]
	public class main extends Sprite
	{
		
		public function main()
		{
			//Must import and reference any definition that could be instantiated from xml
			BreakableObject;
			BreakableProp;
			PhysicsProp;
			TriggerProp;
			SimpleProp;
			
			//Initialize the game
			GameManager.Initizalize(stage);
		}
	}
}
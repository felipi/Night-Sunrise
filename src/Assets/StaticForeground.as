package Assets 
{
	import flash.display.Sprite;
	import Graphics.Levels.GameLevel;
	
	/**
	 * ...
	 * @author Felipi
	 */
	public class StaticForeground extends Sprite
	{
		
		public function StaticForeground() 
		{
			GameLevel.staticLayers.push(this);
		}
		
	}

}
package Assets
{
	import flash.utils.setTimeout;
	import System.GameManager;
	
	import flash.display.MovieClip;
	
	public class PlayerSpawn extends PlayerDepth
	{
		public function PlayerSpawn(xx : Number = -1, yy : Number = -1)
		{
			if (xx >= 0) this.x = xx;
			if (yy >= 0) this.y = yy;
			
			GameManager.actor.x = this.x;
			GameManager.actor.y = this.y;
			
			//trace("Player Created");
			//trace("PARENT " , parent);
			
			visible = false;
			setTimeout( RemoveFromParent , 10);
			
			//trace( "<player x='" + x + "' y='" + y + "'> </player>");
		}
		
		private function RemoveFromParent():void
		{
			this.parent.removeChild(this);
		}
	}
}
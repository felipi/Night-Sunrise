package Actions 
{
	import System.GameManager;

	/**
	 * ...
	 * @author Felipi
	 */
	public class ActionProxy
	{
		
		public function ActionProxy() 
		{
			
		}
		
		//Traces a message. @text:String
		public static function Trace(params:Object) : void {
			GameManager.DTrace(params["text"]);
		}
		
	}

}
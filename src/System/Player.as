package System
{
	import Data.Character;
	import Data.Global;
	
	import Graphics.Characters.Actor;
	
	import System.Input.ActorInput;
	import System.Input.EditorInput;
	import System.Input.GameInput;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Player extends EventDispatcher
	{
		
		public var character : Character;
		public var actor : Actor;
		public var input : GameInput;
		
		public function Player()
		{
			if(GameManager.EDITOR){
				input = new EditorInput();
			}else{
				input = new ActorInput();
			}
			character = new Character(Global.playerName);
			actor = new Actor("Spritesheets:" + Global.playerName);
			
			input.addEventListener(ActorInput.WALK_LEFT, WalkLeft);
			input.addEventListener(ActorInput.WALK_RIGHT, WalkRight);
			input.addEventListener(ActorInput.CLIMB, Climb);
			//input.addEventListener(ActorInput.FALL, Fall);
			input.addEventListener(ActorInput.IDLE, Idle);
			input.addEventListener(ActorInput.JUMP, Jump);
		}
		
		private function WalkLeft(e:Event): void{ actor.Walk(false); }
		private function WalkRight(e:Event): void{ actor.Walk(true); }
		private function Climb(e:Event): void{ actor.Climb(); }
		//private function Fall(e:Event): void{ actor.Fall(); }
		private function Idle(e:Event): void{ actor.Idle(); }
		private function Jump(e:Event): void{ actor.Jump(); }
	}
}
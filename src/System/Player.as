package System
{
	import Data.Character;
	import Data.Global;
	
	import Graphics.Characters.BaseActor;
	import Graphics.Characters.HeroActor;
	
	import System.Input.ActorInput;
	import System.Input.EditorInput;
	import System.Input.GameInput;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class Player extends EventDispatcher
	{
		
		public var character : Character;
		public var actor : HeroActor;
		public var input : GameInput;
		
		public function Player()
		{
			if(GameManager.EDITOR){
				input = new EditorInput();
			}else{
				input = new ActorInput();
			}
			character = new Character(Global.playerName);
			actor = new HeroActor("Spritesheets:" + Global.playerName);
			
			input.addEventListener(ActorInput.WALK_LEFT, WalkLeft);
			input.addEventListener(ActorInput.WALK_RIGHT, WalkRight);
			input.addEventListener(ActorInput.CLIMB, Climb);
			input.addEventListener(ActorInput.IDLE, Idle);
			input.addEventListener(ActorInput.JUMP, Jump);
			input.addEventListener(ActorInput.BLOCK, Block);
		}
		
		private function WalkLeft(e:Event): void{ actor.PerformAction("WALK", false); }
		private function WalkRight(e:Event): void{ actor.PerformAction("WALK", true); }
		private function Climb(e:Event): void{ actor.PerformAction("CLIMB"); }
		private function Idle(e:Event): void{ actor.PerformAction("IDLE"); }
		private function Jump(e:Event): void{ actor.PerformAction("JUMP"); }
		private function Block(e:Event): void{ actor.PerformAction("BLOCK"); }
	}
}
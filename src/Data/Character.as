package Data
{
	import Graphics.Characters.Actor;
	
	import flash.display.Sprite;

	public class Character
	{
		public var name : String;
		public var level : Number = 1;
		public var maxLevel : Number = 30;
		public var experience : Number = 0;
		public var experienceRate : Number = 1;
		public var requiredExperienceForNextLevel : Number;
		public var life : Number;
		public var maxLife : Number = 100;
		public var magic : Number;
		public var macMagic : Number = 100;
		public var equips : Array = new Array(3);
		public var items : Array = new Array();
		public var skills : Array = new Array();
		
		public function Character(charName : String) {
			name = charName;
			
			requiredExperienceForNextLevel = level * experienceRate * 100;
			equips[0] = new Weapon();

		}
		
	}
}
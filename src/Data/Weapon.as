package Data
{
	public class Weapon
	{
		public var name : String = "noname";
		public var icon : String = "none";
		public var level : Number = 1;
		public var maxLevel : Number = 3;
		private var _experience : Number = 0;
		public var atk : Number = 5; //attack
		public var def : Number = 5; //defense
		public var spd : Number = 5; //speed
		public var rng : Number = 2; //range
		public var skillSlots : Number = 2;
		public var skills : Array;
		
		public function Weapon()
		{
			////trace("Weapon: ", name);
		}
		
		public function set experience(value:Number):void{
			////trace(value);
			_experience = value;
			while (_experience > 100){
				////trace("LevelUP");
				_experience -= 100;
				level++
			}
		}
		
		public function get experience():Number {
			return _experience;
		}
	}
}
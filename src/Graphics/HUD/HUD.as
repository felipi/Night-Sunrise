package Graphics.HUD {
	import Data.Weapon;
	
	import Graphics.FX.Filters.FilterCollection;
	import System.GameManager;
	
	import flash.display.MovieClip;
	import flash.display.Shader;
	
	public class HUD extends MovieClip
	{
		//[Embed (source="../../../Resources/Graphics/HUD/iconBackground.png")]
		private var iconSrc : Class;
		//[Embed (source="../../../Resources/Graphics/HUD/iconOverlay.png")]
		private var overSrc : Class;
		//[Embed (source="../../../Resources/Blendings/hardlight.pbj", mimeType="application/octet-stream")]
		private var hardLight : Class;
		
		public var maskRect : MovieClip = new MovieClip();
		
		public function HUD()
		{
			this.addChildAt(new iconSrc(), 0);
			this.addChildAt(new overSrc(), 1);
			this.addChildAt(maskRect, 2);
			
			var fc : FilterCollection = new FilterCollection();
			var blending : Shader = fc.GetShader(fc.AddFilter(hardLight));
			
			this.getChildAt(1).blendShader = blending;
			this.getChildAt(1).mask = this.getChildAt(2);	
			
			Refresh();
		}
		
		public function Refresh(): void{
			var weapon : Weapon = GameManager.player.character.equips[0];
			
			var w:Number = this.getChildAt(1).width;
			var h:Number = this.getChildAt(1).height * weapon.experience / 100;
			maskRect.graphics.beginFill(0x000000);
			maskRect.graphics.drawRect(0, 0, w, h);
			maskRect.graphics.endFill();
			maskRect.y = this.getChildAt(1).height - h;
			
		}
	}
}
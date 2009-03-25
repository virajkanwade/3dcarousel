package ml_components
{
	import com.GSLab.ThreeDCarousel.CarouselItem;
	
	import mx.containers.HBox;
	import mx.controls.Label;
	
	public class ExampleCarouselItem extends CarouselItem
	{
		private var lbl:Label;

		public function ExampleCarouselItem():void {
			setItemStyle();
			
			lbl = new Label();
			lbl.percentWidth = 100;
			lbl.setStyle('textAlign', 'center');

			addChild(lbl);
		}
		
		private function setItemStyle():void {
			this.setStyle('verticalAlign', 'center');
			this.setStyle('horizontalAlign', 'center');
			this.setStyle('borderStyle', 'solid');
			this.setStyle('borderColor', 'white');
			this.setStyle('borderThickness', '2');
			this.setStyle('cornerRadius', '10');
			this.setStyle('backgroundColor', '#0F7E88');
			this.setStyle('color', 'white');
		}
		
		public function set title(title:String):void {
			//lbl.text = title;
			lbl.htmlText = '<b>' + title + '</b>';
			//lbl.x = this.width/2 - lbl.width/2;
		}
	}
}
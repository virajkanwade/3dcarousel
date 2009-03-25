/* Copyright (c) 2009 Viraj Kanwade., published under the BSD license. */
package com.GSLab.ThreeDCarousel
{
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	public class ThreeDCarousel extends UIComponent
	{
		//Set the focal length
		[Bindable]
		public var focalLength:Number = 500;
		 
		//Set the vanishing point
		[Bindable]
		public var vanishingPointX:Number;// = stage.stageWidth / 2;
		
		[Bindable]
		public var vanishingPointY:Number;// = stage.stageHeight / 2;
		 
		//The 3D floor for the images
		[Bindable]
		public var floor:Number = 40;
		 
		//We calculate the angleSpeed in the ENTER_FRAME listener
		[Bindable]
		public var angleSpeed:Number = 0;
		 
		//Radius of the circle
		[Bindable]
		public var radius:Number = 200;
		 
		//The total number of items in itemHolders
		[Bindable]
		private var numberOfItems:uint = 0;
 
		//This array will contain all the itemHolders
		[Bindable]
		private var itemHolders:Array;
		
		[Bindable]
		public var direction:String = "horizontal";
		
		[Bindable]
		public var defaultItemAlpha:Number = 0.6;
		
		public function ThreeDCarousel()
		{
			itemHolders = new Array();
		}
		
		public function set items(items:Array):void {
			itemHolders = items;
			numberOfItems = itemHolders.length;
		}
		
		public function windowResized():void {
			getVanishingPoint();
		}
		
		private function getVanishingPoint():void {
			if(direction == "horizontal") {
				vanishingPointX = this.parent.width / 2 - (radius/2);
				vanishingPointY = this.parent.height / 2 - (radius/2);
			} else {
				vanishingPointX = this.parent.width / 2 - (itemHolders[0].width/2);
				vanishingPointY = this.parent.height / 2 - (radius/2);
			}
		}

		//This function is called when all the images have been loaded.
		//Now we are ready to create the 3D carousel.
		public function initializeCarousel():void {
			if(numberOfItems <= 0) {
				return;
			}
			getVanishingPoint();

			//Calculate the angle difference between the images (in radians)
			var angleDifference:Number = Math.PI * (360 / numberOfItems) / 180;
		 
			//Loop through the images
			for (var i:uint = 0; i < itemHolders.length; i++) {
		 
				//Assign the imageHolder to a local variable
				//var itemHolder:MovieClip = (MovieClip)(itemsHolder[i]);
				var itemHolder:* = (itemHolders[i]);
		 
				//Get the angle for the image (we space the images evenly)
				var startingAngle:Number = angleDifference * i;
		 
				//Set a "currentAngle" attribute for the imageHolder
				itemHolder.currentAngle = startingAngle;

				//Position the imageHolder
				if(direction == 'horizontal') {
					itemHolder.xpos3D = radius * Math.cos(startingAngle);
					itemHolder.zpos3D = radius * Math.sin(startingAngle);
					itemHolder.ypos3D = floor;
				} else {
					itemHolder.xpos3D =  -  radius * Math.cos(itemHolder.currentAngle) * 0.5;
					itemHolder.ypos3D = radius * Math.sin(startingAngle);
					itemHolder.zpos3D = radius * Math.cos(startingAngle);
				}

				//Calculate the scale ratio for the imageHolder (the further the image -> the smaller the scale)
				var scaleRatio:Number = focalLength/(focalLength + itemHolder.zpos3D);
		 
				//Scale the imageHolder according to the scale ratio
				itemHolder.scaleX = itemHolder.scaleY = scaleRatio;
		 
				//Set the alpha for the imageHolder
				itemHolder.alpha = defaultItemAlpha;
		 
				//Position the imageHolder to the stage (from 3D to 2D coordinates)
				itemHolder.x = vanishingPointX + itemHolder.xpos3D * scaleRatio;
				itemHolder.y = vanishingPointY + itemHolder.ypos3D * scaleRatio;
		 
				//We want to know when the mouse is over and out of the imageHolder
				itemHolder.addEventListener(MouseEvent.MOUSE_OVER, mouseOverItem);
				itemHolder.addEventListener(MouseEvent.MOUSE_OUT, mouseOutItem);
		 
				//We also want to listen for the clicks
				//TODO//itemHolder.addEventListener(MouseEvent.CLICK, imageClicked);
		 
				//Add the imageHolder to the stage
				addChild(itemHolder);
			}
		 
			//Add an ENTER_FRAME for the rotation
			addEventListener(Event.ENTER_FRAME, rotateCarousel);
		}
		
		private function rotateCarousel(e:Event):void {
			//Calculate the angleSpeed according to mouse position
			if(direction == "horizontal") {
				angleSpeed = (mouseX - vanishingPointX) / 4096;
			} else {
				angleSpeed = (mouseY - vanishingPointY) / 4096;
			}
		 
			//Loop through the images
			for (var i:uint = 0; i < itemHolders.length; i++) {
		 
				//Assign the imageHolder to a local variable
				//var itemHolder:MovieClip = (MovieClip)(itemHolders[i]);
				var itemHolder:* = (itemHolders[i]);

				//Update the imageHolder's current angle
				itemHolder.currentAngle += angleSpeed;
		 
				//Calculate a scale ratio
				var scaleRatio:Number = focalLength/(focalLength + itemHolder.zpos3D);
		 
				//Set a new 3D position for the imageHolder
				if(direction == "horizontal") {
					itemHolder.xpos3D=radius*Math.cos(itemHolder.currentAngle);
					itemHolder.zpos3D=radius*Math.sin(itemHolder.currentAngle);
				} else {
					itemHolder.xpos3D=- radius*Math.cos(itemHolder.currentAngle)*0.5;
					itemHolder.ypos3D=radius*Math.sin(itemHolder.currentAngle);
					itemHolder.zpos3D=radius*Math.cos(itemHolder.currentAngle);
				}

				//Scale the imageHolder according to the scale ratio
				itemHolder.scaleX=itemHolder.scaleY=scaleRatio;
		 
				//Update the imageHolder's coordinates
				itemHolder.x=vanishingPointX+itemHolder.xpos3D*scaleRatio;
				itemHolder.y=vanishingPointY+itemHolder.ypos3D*scaleRatio;
			}

			//Call the function that sorts the images so they overlap each others correctly
			sortZ();
		}
	 
		//This function sorts the images so they overlap each others correctly
		private function sortZ():void {
		 
			//Sort the array so that the image which has the highest 
			//z position (= furthest away) is first in the array
			itemHolders.sortOn("zpos3D", Array.NUMERIC | Array.DESCENDING);
		 
			//Set new child indexes for the images
			for (var i:uint = 0; i < itemHolders.length; i++) {
				setChildIndex(itemHolders[i], i);
			}
		}
		
		//This function is called when the mouse is over an imageHolder
		private function mouseOverItem(e:Event):void {
 
			//Set alpha to 1
			e.target.alpha=1;
		}
 
		//This function is called when the mouse is out of an imageHolder
		private function mouseOutItem(e:Event):void {
			//Set alpha to default
			e.target.alpha=defaultItemAlpha;
		}
 
 		/**
		//This function is called when an imageHolder is clicked
		private function imageClicked(e:Event):void {
			//Navigate to the URL that is in the "linkTo" variable
			navigateToURL(new URLRequest(e.target.linkTo));
		}
		**/

	}
}
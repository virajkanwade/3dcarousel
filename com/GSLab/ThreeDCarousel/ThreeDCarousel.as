/* Copyright (c) 2009 Viraj Kanwade., published under the BSD license. */
package com.GSLab.ThreeDCarousel
{
	import flash.events.Event;
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
		
		// This will determine the direction of carousel 
		[Bindable]
		public var direction:String = "horizontal";
		
		// The alpha for items
		[Bindable]
		public var defaultItemAlpha:Number = 0.6;
		
		// The item click handler.
		[Bindable]
		public var itemClickHandler:Function;
		
		// Constructor
		public function ThreeDCarousel()
		{
			itemHolders = new Array();
		}
		
		public function set items(items:Array):void {
			itemHolders = items;
			numberOfItems = itemHolders.length;
		}
		
		public function get items():Array {
			return itemHolders;
		}
		
		public function windowResized():void {
			if(this.parent != null) {
				getVanishingPoint();
			}
		}
		
		private function getVanishingPoint():void {
			if(direction == "horizontal") {
				vanishingPointX = (this.parent.width - itemHolders[0].width) / 2;
				vanishingPointY = (this.parent.height - radius - itemHolders[0].height) / 2;
			} else {
				vanishingPointX = (this.parent.width - itemHolders[0].width) / 2;
				vanishingPointY = (this.parent.height - radius) / 2;

				// This is a dirty hack to try and get the carousel in the center of the parent.
				var bbox:Object = getBBoxOfCarousel();
				if(bbox.min_x < 0) {
					bbox.min_x = - bbox.min_x;
				}
				if(bbox.max_x < 0) {
					bbox.max_x = - bbox.max_x;
				}
				if(bbox.min_y < 0) {
					bbox.min_y = - bbox.min_y;
				}
				if(bbox.max_y < 0) {
					bbox.max_y = - bbox.max_y;
				}
				
				vanishingPointX = (this.parent.width - (bbox.max_x - bbox.min_x)) / 2 + 15;
				vanishingPointY = (bbox.min_y + bbox.max_y) / 2;
			}
		}

		private function getBBoxOfCarousel():Object {
			var bbox:Object = new Object();
			//Calculate the angle difference between the images (in radians)
			var angleDifference:Number = Math.PI * (360 / numberOfItems) / 180;

			var xpos3D:Number;
			var ypos3D:Number;
			var zpos3D:Number;
			
			bbox.min_x = 100000;
			bbox.max_x = -100000;
			bbox.min_y = 100000;
			bbox.max_y = -100000;

			//Loop through the images
			for (var i:uint = 0; i < itemHolders.length; i++) {
				//Get the angle for the image (we space the images evenly)
				var startingAngle:Number = angleDifference * i;
		 
				//Position the imageHolder
				if(direction == 'horizontal') {
					xpos3D = radius * Math.cos(startingAngle);
					//ypos3D = floor;
					ypos3D = radius * Math.cos(startingAngle);
					zpos3D = radius * Math.sin(startingAngle);
				} else {
					xpos3D =  -  radius * Math.cos(startingAngle) * 0.5;
					ypos3D = radius * Math.sin(startingAngle);
					zpos3D = radius * Math.cos(startingAngle);
				}

				//Calculate the scale ratio for the imageHolder (the further the image -> the smaller the scale)
				var scaleRatio:Number = focalLength/(focalLength + zpos3D);
		 
		 		var X:Number = vanishingPointX + xpos3D * scaleRatio;
				var Y:Number = vanishingPointY + ypos3D * scaleRatio;

		 		if(bbox.min_x > X) {
		 			bbox.min_x = X;
		 		}
		 		if(bbox.max_x < X) {
		 			bbox.max_x = X;
		 		}
		 		if(bbox.min_y > Y) {
		 			bbox.min_y = Y;
		 		}
		 		if(bbox.max_y < Y) {
		 			bbox.max_y = Y;
		 		}
			}
			
		 	bbox.max_x += itemHolders[0].width;
 			bbox.max_y += itemHolders[0].height;
			return bbox;
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
		 
				//Position the imageHolder
				if(direction == 'horizontal') {
					itemHolder.xpos3D = radius * Math.cos(startingAngle);
					itemHolder.zpos3D = radius * Math.sin(startingAngle);
					itemHolder.ypos3D = floor;
				} else {
					itemHolder.xpos3D =  -  radius * Math.cos(startingAngle) * 0.5;
					itemHolder.ypos3D = radius * Math.sin(startingAngle);
					itemHolder.zpos3D = radius * Math.cos(startingAngle);
				}

				//Set a "currentAngle" attribute for the imageHolder
				itemHolder.currentAngle = startingAngle;

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
				if(itemClickHandler != null) {
					itemHolder.addEventListener(MouseEvent.CLICK, itemClickHandler);
				}
		 
				//Add the imageHolder to the stage
				addChild(itemHolder);
			}
		}
		
		public function resetCarousel():void {
			stopCarousel();
			if(numberOfItems <= 0) {
				return;
			}
			
			//Loop through the images
			//for (var i:uint = 0; i < itemHolders.length; i++) {
			while(itemHolders.length > 0) {
		 
				//Assign the imageHolder to a local variable
				//var itemHolder:MovieClip = (MovieClip)(itemsHolder[i]);
				var itemHolder:* = itemHolders.pop();
				
				itemHolder.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverItem);
				itemHolder.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutItem);
		 
				if(itemClickHandler != null) {
					itemHolder.removeEventListener(MouseEvent.CLICK, itemClickHandler);
				}
		 
				removeChild(itemHolder);

				itemHolder = null;
			}
			numberOfItems = 0;
		}

		public function startCarousel():void {
			if(numberOfItems <= 0) {
				Alert.show("No items have been added to the carousel", "Error");
			}

			//Add an ENTER_FRAME for the rotation
			addEventListener(Event.ENTER_FRAME, rotateCarousel);
		}
		
		public function stopCarousel():void {
			removeEventListener(Event.ENTER_FRAME, rotateCarousel);
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
			/*
				It may be possible that the itemHolder has childNodes and this event was fired by one. 
				So get the itemHolder.
			*/
 			var obj:* = e.target;
 			while(!(obj.parent is ThreeDCarousel)) {
 				obj = obj.parent;
 			}
			//Set alpha to 1
			obj.alpha = 1;
		}
 
		//This function is called when the mouse is out of an imageHolder
		private function mouseOutItem(e:Event):void {
			/*
				It may be possible that the itemHolder has childNodes and this event was fired by one. 
				So get the itemHolder.
			*/
 			var obj:* = e.target;
 			while(!(obj.parent is ThreeDCarousel)) {
 				obj = obj.parent;
 			}

			//Set alpha to default
			obj.alpha = defaultItemAlpha;
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
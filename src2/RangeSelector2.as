package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import mx.charts.chartClasses.*;
	import mx.controls.*;
	
	public class RangeSelector2 extends ChartElement {    
		/* The bounds of the selected region. */
		private var dLeft:Number = 20;
		private var dTop:Number = 20;
		private var dRight:Number = 80;
		private var dBottom:Number = 80;
		
		// The width of the rectangle drawn.
		private var rectWidth:Number;
		
		/* The x/y coordinates of the start of the tracking region. */
		private var tX:Number;
		private var tY:Number;
		
		/* Whether or not a region is selected. */
		private var bSet:Boolean = false;
		
		/* Whether or not we're currently tracking. */        
		private var bTracking:Boolean = false;
		
		/* The four labels for the data bounds of the selected region. */
		private var _labelLeft:Label;
		private var _labelRight:Label;
		
		/* Constructor. */
		public function RangeSelector2():void
		{
			super();
			setStyle("color",0);
			/* mousedowns are where we start tracking the selection */
			addEventListener("mouseDown",startTracking);
			
			/* create our labels */
			_labelLeft = new Label();
			_labelRight = new Label();
			addChild(_labelLeft);
			addChild(_labelRight);
		}
		
		/* Draw the overlay. */
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var g:Graphics = graphics;
			g.clear();
			
			// Draw a big transparent square so Flash Player sees us for mouse eventss */
			g.moveTo(0,0);
			g.lineStyle(0,0,0);
			g.beginFill(0,0);
			g.drawRect(0,0,unscaledWidth,unscaledHeight);
			g.endFill();
			
			/* Draw the selected region, if there is one. */
			if(bSet)
			{
				/* 
				*  The selection is a data selection, so we want to make sure the region stays correct as the chart changes size and/or ranges.
				*  so we store it in data coordinates. So before we draw it, we need to transform it back into screen coordinates.
				*/
				var c:Array = [{dx: dLeft, dy: dTop}, {dx:dRight, dy: dBottom}];
				dataTransform.transformCache(c,"dx","x","dy","y");
				
				/* Now draw the region on screen. */
				g.moveTo(c[0].x,c[0].y);                
				g.beginFill(0xEEEE22,.2);
				g.lineStyle(1,0xBBBB22);
				rectWidth = c[1].x - c[0].x;
				g.drawRect(c[0].x,0,4, parentApplication.myChartPlot.height);
				g.endFill();
				
				/* Now we're going to position the labels at the edges of the box. */
				_labelLeft.visible = _labelRight.visible = true;                
				_labelLeft.setActualSize(_labelLeft.measuredWidth,_labelLeft.measuredHeight);
				_labelLeft.move(c[0].x - _labelLeft.width/2,c[1].y + 24);
				_labelRight.setActualSize(_labelRight.measuredWidth,_labelRight.measuredHeight);
				_labelRight.move(c[1].x - _labelRight.width/2,c[1].y + 24 );
			} else {
				_labelLeft.visible = _labelRight.visible = false;
				rectWidth=0;
			}
		}
		
		private var leftDate:Date;
		private var rightDate:Date;
		
		override protected function commitProperties():void
		{    
			super.commitProperties();
			
			leftDate = new Date(dLeft);
			rightDate = new Date(dRight);
			_labelLeft.text = (leftDate.getMonth()+1) + "/" + leftDate.getDate() + "/" + leftDate.getFullYear();
			_labelRight.text = (rightDate.getMonth()+1) + "/" + rightDate.getDate() + "/" + rightDate.getFullYear();            
		}
		
		
		override public function mappingChanged():void
		{
			/* since we store our selection in data coordinates, we need to redraw when the mapping between data coordinates and screen coordinates changes
			*/
			invalidateDisplayList();
		}
		
		private function startTracking(e:MouseEvent) :void
		{
			/* the user clicked the mouse down. First, we need to add listeners for the mouse dragging */
			bTracking = true;
			parentApplication.addEventListener("mouseUp",endTracking,true);
			parentApplication.addEventListener("mouseMove",track,true);
			
			/* now store off the data values where the user clicked the mouse */
			var dataVals:Array = dataTransform.invertTransform(mouseX,mouseY);
			tX = dataVals[0];
			tY = dataVals[1];
			bSet = false;
			rectWidth=0;
			
			updateTrackBounds(dataVals);
		}
		
		private function track(e:MouseEvent):void {
			if(bTracking == false)
				return;
			bSet = true;
			updateTrackBounds(dataTransform.invertTransform(mouseX,mouseY));
			e.stopPropagation();
		}
		
		private function endTracking(e:MouseEvent):void {
			/* The selection is complete, so remove our listeners and update one last time to match the final position of the mouse */
			bTracking = false;
			parentApplication.removeEventListener("mouseUp",endTracking,true);
			parentApplication.removeEventListener("mouseMove",track,true);
			e.stopPropagation();
			
			// if the rect is just a click or less than 3 pixels, then ignore
			if (rectWidth>=3) {
				parentApplication.minDate = new Date(dLeft);
				parentApplication.maxDate = new Date(dRight);
				
				// increase the size of the data point by approximately the same ratio as the width of the chart is to the selection area
				var plotPointRatio:Number = rectWidth/parentApplication.myChartPlot.width;
				var curRadius:int = parentApplication.series1.getStyle("radius");
				parentApplication.series1.setStyle("radius", curRadius *(1 - plotPointRatio + 1));
				parentApplication.series2.setStyle("radius", curRadius *(1 - plotPointRatio + 1));
				parentApplication.series3.setStyle("radius", curRadius *(1 - plotPointRatio + 1));
			}
			// reset selection mode
			bSet = false; 
			// reset width of rectangle
			rectWidth=0;           
		}
		private function updateTrackBounds(dataVals:Array):void
		{
			/* Store the bounding rectangle of the selection, in a normalized data-based rectangle */
			dRight = Math.max(tX,dataVals[0]);
			dLeft = Math.min(tX,dataVals[0]);
			dBottom = Math.min(tY,dataVals[1]);
			dTop = Math.max(tY,dataVals[1]);
			
			/* Invalidate our data, and redraw */
			dataChanged();
			invalidateProperties();
			invalidateDisplayList();            
		}        
	}
}
import com.adobe.serialization.json.JSON;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.utils.ByteArray;

import fr.kapit.components.treemap.ITreeMapInfo;
import fr.kapit.components.treemap.TreeMap;
import fr.kapit.components.treemap.TreeMapLegend;

import mx.charts.AreaChart;
import mx.charts.BarChart;
import mx.charts.CategoryAxis;
import mx.charts.ColumnChart;
import mx.charts.GridLines;
import mx.charts.Legend;
import mx.charts.LineChart;
import mx.charts.PlotChart;
import mx.charts.series.AreaSeries;
import mx.charts.series.BarSeries;
import mx.charts.series.ColumnSeries;
import mx.charts.series.LineSeries;
import mx.charts.series.PlotSeries;
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Panel;
import mx.containers.VBox;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.graphics.ImageSnapshot;
import mx.graphics.SolidColor;
import mx.graphics.SolidColorStroke;
import mx.graphics.Stroke;
import mx.graphics.codec.JPEGEncoder;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.alivepdf.display.Display;
import org.alivepdf.images.ColorSpace;
import org.alivepdf.layout.Layout;
import org.alivepdf.layout.Orientation;
import org.alivepdf.layout.Resize;
import org.alivepdf.layout.Size;
import org.alivepdf.layout.Unit;
import org.alivepdf.pdf.PDF;
import org.alivepdf.saving.Method;

import spark.components.ResizeMode;

private var myPDF:PDF;
private var config:Object;
[Bindable]
private var modelConfig:Object;

[Bindable]
private var heatmapArray:ArrayCollection=new ArrayCollection();

[Bindable]
private var tmpArray:ArrayCollection=new ArrayCollection();
[Bindable]
private var modelPartList:ArrayCollection=new ArrayCollection();
private var signalError:Boolean;
private var signalData:Array;
private var file:FileReference = new FileReference();
[Bindable]
private var aTemp:Array= new Array();

[Bindable]
private var poptrid:String;

[Bindable]
private var popidString:String="";
[Bindable]
public var myChartLine:LineChart=new LineChart();
[Bindable]
public var legendLine:Legend= new Legend();
[Bindable]
public var myChartPlot:PlotChart=new PlotChart();
[Bindable]
public var legendPlot:Legend= new Legend();
[Bindable]
public var myChartArea:AreaChart=new AreaChart();
[Bindable]
public var legendArea:Legend= new Legend();

[Bindable]
public var myChartColumn:ColumnChart=new ColumnChart();
[Bindable]
public var legendColumn:Legend= new Legend();

[Bindable]
public var myChartBar:BarChart=new BarChart();
[Bindable]
public var legendBar:Legend= new Legend();


[Bindable]
public var myChartTree:fr.kapit.components.treemap.TreeMap=new TreeMap();
[Bindable]
public var legendTree:TreeMapLegend= new TreeMapLegend();

[Bindable]
private var explotArraycol:ArrayCollection=new ArrayCollection();
[Bindable]
private var intType:String=new String();

[Bindable]
public var cantfind:String="";
private function eplant_init2() : void {
	serve_getConfigData.send();
}


// Flashvar init
private function eplant_init():void{


	input_AGI.text = FlexGlobals.topLevelApplication.parameters.id;
	intType= FlexGlobals.topLevelApplication.parameters.type;
	//input_GO.text="GO:0043231"
	if(input_AGI.text!=""){
		dataSend();
	}else{
		input_AGI.text="POPTR_0001s28340, POPTR_0001s28400";
		intType="bar";
		dataSend();
	}

	
	
	
	
	//serve_getConfigData.send();
}
private function dataSend():void{
	//	var g: Graph = new Graph();
	//s.dataProvider=[];
	explotArraycol=new ArrayCollection();
		
	var str:String =input_AGI.text;
	var pattern:RegExp = /,/gi;
	var a:Array = str.replace(pattern, " ").split(/\s+/);
	for(var h:int=0;h<a.length;h++){
		var base:String = modelConfig.settings.url+"?primaryGene="+a[h]+"&type="+intType;//	serve_getTranscriptData.url =modelConfig.settings.url+"?id="+a[h];
		serve_getExpressionData.url = base ;
		serve_getExpressionData.send();
	}
	
	
	
}

//FLashvar init end


private function handle_config_files(event:ResultEvent):void {
	modelConfig = (JSON.decode(String(event.result)));
	loadPolFile(modelConfig.settings.policy_file);
}

private function onClickbutton():void{
	//aTemp= new Array();
	//if(modelPartList!=null){
	//modelPartList.removeAll();// = new ArrayCollection();
	//}//modelPartList = null;
	modelPartList=new ArrayCollection();
cantfind=new String();

legendColumn= new Legend();
myChartColumn.series=new Array();

legendPlot= new Legend();
myChartPlot.series=new Array();

legendBar= new Legend();
myChartBar.series=new Array();

legendArea= new Legend();
myChartArea.series=new Array();

	legendLine= new Legend();
	myChartLine.series=new Array();
	
	
	tmpArray=new ArrayCollection();
	
	p4.removeAllChildren();
	
	///chartLegend= new Legend();
	///myChart6.series=new Array();

	var str:String =input_AGI.text;
	var pattern:RegExp = /,/gi;
	var a:Array = str.replace(pattern, " ").split(/\s+/);
	for(var h:int=0;h<a.length;h++){
		var base:String = modelConfig.settings.url+"?primaryGene="+a[h];//	serve_getTranscriptData.url =modelConfig.settings.url+"?id="+a[h];
		serve_getExpressionData.url = base ;
		serve_getExpressionData.send();
		
	}

}

/**
 *  Retrieve the expression data results from the web service handler.
 */
private function expressionDataResult(event:ResultEvent):Boolean {
	if (signalError) {
		Alert.show("SE");
		return false; }
	var exprData:Object = JSON.decode(String(event.result));
	//exprDatachartfinal = exprData;
	
	if (exprData["error"] == undefined) {
		poptrid = new String(exprData['poptr'][0]);
		// A loop is used in case a future script will provide more sample details to record
		for (var name:String in exprData['signals']) {
			var numberValue:Number = new Number(exprData['signals'][name]['value']);
			var popid:String = new String(exprData['signals'][name]['id']);
			//exprData[name]=numberValue.toFixed(2);
			//var expTemp:Number=exprData[name];
			//expall+=numberValue;
			aTemp.push({id:poptrid,data:numberValue,label:popid});
			tmpArray.addItem({id:poptrid,data:numberValue,label:popid});
			//signalData[name] = exprData[name];
			//shows up as ATGE_CTRL_7
			//Alert.show(signalData[name].toString());
		}
		//modelPartList.addItem(aTemp);
		
	}
	if(exprData['signals']!=null){
		sortCollection(tmpArray);
	modelPartList=new ArrayCollection(aTemp);
	modelPartList.refresh();
	sortCollection(modelPartList);
	if(lineChart.selected){
	CreateLineChart();
	}else if(plotchart.selected){
	CreatePlotChart();
	}else if(areachart.selected){
		CreateAreaChart();
	}else if(columnchart.selected){
		CreateColumnChart();
	}else if(barchart.selected){
		CreateBarChart();
	}else{
		CreateTree();
	}
    ///var localSeries:LineSeries = new LineSeries(); 
	///localSeries.dataProvider = modelPartList; 
	///localSeries.yField = "data"; 
	///localSeries.xField = "label"; 
	
	// Set values that show up in dataTips and Legend. 
	///localSeries.displayName =poptrid; 
	// Back up the current series on the chart. 
	///var currentSeries:Array = myChart6.series; 
	// Add the new series to the current Array of series. 
	///currentSeries.push(localSeries); 
	// Add the new Array of series to the chart. 
	///myChart6.series = currentSeries;
	aTemp=new Array();
	}else{
		cantfind+=poptrid.toString()+'\n';
	}
	return true;
}


/**
 *  Create dynamic line Chart
 */

public function CreateLineChart():void {
	
	var series2:LineSeries= new LineSeries();

	
	//var s:SolidColorStroke = new SolidColorStroke(0xff00ff, 30);
	//series2.setStyle("stroke",s);
	//myChartLine.annotationElements = [series2]
	
	myChartLine.showDataTips = true;
	myChartLine.dataProvider = modelPartList;

	/* Define the category axis. */
	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "label" ;
	myChartLine.horizontalAxis = hAxis;

	var mySeries:Array=myChartLine.series;
	series2.dataProvider = aTemp;
	series2.xField="label";
	series2.yField="data";
	//series2.setStyle("lineStroke", new Stroke(series2.getStyle('color') ,2, 0.4));
	//var bgi:LineSeries = new LineSeries();
	//series2.setStyle("lineStroke",s3 );
	myChartLine.seriesFilters = [];
	
	series2.displayName = poptrid;
	
	mySeries.push(series2);
	myChartLine.series = mySeries;

	myChartLine.percentWidth=100;
	myChartLine.percentHeight=100;

	legendLine.dataProvider = myChartLine;
	myChartLine.styleName="linechart";
	

	
	
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartLine);
	p4.addElement(legendLine);
	
}

/**
 *  Create dynamic plot Chart
 */

public function CreatePlotChart():void {
	
	var series2:PlotSeries;

	myChartPlot.showDataTips = true;
	myChartPlot.dataProvider = modelPartList;
	//
	/* Define the category axis. */
	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "label" ;
	myChartPlot.horizontalAxis = hAxis;

	/* Add the series. */
	var mySeries:Array=myChartPlot.series;//=new Array();

	series2 = new PlotSeries();
	series2.dataProvider=modelPartList;
	series2.xField="label";
	series2.yField="data";
	series2.displayName = poptrid;
	//series2.itemRenderer=mx.charts.renderers.CircleItemRenderer;
	mySeries.push(series2);
	var bgi:RangeSelector=new RangeSelector();
	/*var bgi:GridLines = new GridLines();
	var s:SolidColorStroke = new SolidColorStroke(0xff00ff, 3);
	bgi.setStyle("horizontalStroke",s);
	var c:SolidColor = new SolidColor(0x990033, .2);
	bgi.setStyle("horizontalFill",c);
	var c2:SolidColor = new SolidColor(0x999933, .2);
	bgi.setStyle("horizontalAlternateFill",c2);*/
	myChartPlot.annotationElements = [bgi]
	
	//myChartPlot.annotationElements=[RangeSelector];
	myChartPlot.seriesFilters = [];
	
	myChartPlot.series = mySeries;
	myChartPlot.percentWidth=100;
	myChartPlot.percentHeight=100;
	//myChart1.height=80;
	/* Create a legend. */
	//legend1 = new Legend();
	legendPlot.dataProvider = myChartPlot;
	myChartPlot.styleName="linechart";
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartPlot);
	p4.addElement(legendPlot);
	
}

/**
 *  Create dynamic plot Chart
 */

public function CreateAreaChart():void {
	
	var series2:AreaSeries;

	myChartArea.showDataTips = true;
	myChartArea.dataProvider = modelPartList;

	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "label" ;
	myChartArea.horizontalAxis = hAxis;

	/* Add the series. */
	var mySeries:Array=myChartArea.series;//=new Array();
	series2 = new AreaSeries();
	series2.dataProvider=modelPartList;
//	series2.xField="label";
	series2.yField="data";
	series2.alpha=0.7;
	series2.displayName = poptrid;	
	mySeries.push(series2);	
	
	myChartArea.series = mySeries;
	myChartArea.percentWidth=100;
	myChartArea.percentHeight=100;

	legendArea.dataProvider = myChartArea;
	myChartArea.styleName="linechart";
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartArea);
	p4.addElement(legendArea);
	
}

/**
 *  Create dynamic CreateColumnChart
 */

public function CreateColumnChart():void {
	
	var series2:ColumnSeries= new ColumnSeries();
	
	myChartColumn.showDataTips = true;
	myChartColumn.dataProvider = modelPartList;
	
	var mySeries:Array=myChartColumn.series;
	
	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "label" ;
	myChartColumn.horizontalAxis = hAxis;

	/* Add the series. */
	//=new Array();
	myChartColumn.seriesFilters = [];
	
	series2.dataProvider=modelPartList;
	series2.xField="label";
	series2.yField="data";
	series2.displayName = poptrid;	
	mySeries.push(series2);	
	
	myChartColumn.series = mySeries;
	myChartColumn.percentWidth=100;
	myChartColumn.percentHeight=100;
	
	legendColumn.dataProvider = myChartColumn;
	myChartColumn.styleName="linechart";
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartColumn);
	p4.addElement(legendColumn);
	
}


/**
 *  Create dynamic CreateColumnChart
 */

public function CreateBarChart():void {
	
	var series3:BarSeries;
	
	myChartBar.showDataTips = true;
	myChartBar.dataProvider = modelPartList;
	
	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "label" ;
	myChartBar.verticalAxis = hAxis;
	myChartBar.seriesFilters = [];
	
	/* Add the series. */
	var mySeries:Array=myChartBar.series;//=new Array();
	series3 = new BarSeries();
	series3.dataProvider=modelPartList;
	series3.yField="label";
	series3.xField="data";
	series3.displayName = poptrid;	
	mySeries.push(series3);	
	
	myChartBar.series = mySeries;
	myChartBar.percentWidth=100;
	myChartBar.percentHeight=100;
	
	legendBar.dataProvider = myChartBar;
	myChartBar.styleName="linechart";
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartBar);
	p4.addElement(legendBar);
	
}
/**
 *  Create dynamic Treemap
 */

public function CreateTree():void {
	
	p4.removeAllChildren();
	
	myChartTree= new fr.kapit.components.treemap.TreeMap(); 
	myChartTree.dataProvider = tmpArray;
	
	
	myChartTree.percentWidth = 100; 
	myChartTree.percentHeight = 100; 
	myChartTree.labelField = "id"; 
	myChartTree.labelField = "label"; 
	myChartTree.enableSelection=true;
	myChartTree.labelHorizontalAlign="label";
	//myChartTree.nodesTextColor=textColorPicker.selectedColor;
	//myChartTree.labelPolicy="all";
	
	myChartTree.colorPolicy="spectrum"
		myChartTree.dynamicTextSize=false;
		
	//	myChartTree.useLogarithmicScale=true;
	//	myChartTree.toolTipField="id";
		myChartTree.labelHorizontalAlign="center";
		myChartTree.labelFunction=labelTipFunction;
		myChartTree.toolTipFunction=toolTipFunction;
		myChartTree.styleName="toolTip";
	//	Alert.show(myChartTree.numChildren.toString());
		//myChartTree.filterPath=["id","label","data"]  ;
		//myChartTree.nodesTextColor="textstyle";
	//myChartTree.showRoot=true;
	//myChartTree.colorField = "data"; 
	myChartTree.colorField ="data";// poptrid;//"label"; 
	//myChartTree.dataTipFunction = poptrid; 
	myChartTree.areaField="data";
	var sampleBox:VBox=new VBox();
	sampleBox.percentHeight=100;
	sampleBox.percentWidth=100;
	legendTree.treeMap=myChartTree;
	legendTree.percentWidth=100;
	legendTree.height=70;
	sampleBox.addChild(myChartTree); 
	sampleBox.addChild(legendTree); 
	p4.addChild(sampleBox);
	//myChartTree.removeChildAt(myChartTree.numChildren-1);
	/* Add the series.
	myChartTree.branchLabelField="data";
	myChartTree.weightField="label";
	myChartTree.labelField="label";

	myChartTree.percentWidth=100;
	myChartTree.percentHeight=100;
	
	legendTree.dataProvider = myChartBar;
	//myChartTree.styleName="linechart";
	/* Attach chart and legend to the display list. 
	p4.addElement(myChartTree);
	p4.addElement(legendTree);*/
	
}

private function clickme(event:MouseEvent):void{
	
}
private function toolTipFunction(data:Object, info:ITreeMapInfo):String
{
	var s:String;
	s=data.data +"\n"+ data.id  +"\n"+data.label
	return s;
}
private function labelTipFunction(data:Object, info:ITreeMapInfo):String
{
	var s:String;
	s= data.id;
	return s;
}

/**
 * SortNames
 */

private function sortCollection(arrayCollection : ArrayCollection) : void
{
	//Create the sort field
	var dataSortField:SortField = new SortField();
	
	//name of the field of the object on which you wish to sort the Collection
	dataSortField.name = "label";
	dataSortField.caseInsensitive = true;
	
	//create the sort object
	var dataSort:Sort = new Sort();
	dataSort.fields = [dataSortField];
	
	arrayCollection.sort = dataSort;
	//refresh the collection to sort
	arrayCollection.refresh();
}
/**
 * take snapshot
 */
private function takeSnapshot():void {
	var bitmapData:BitmapData = new BitmapData(p4.width, p4.height);
	bitmapData.draw(p4,new Matrix());
	var bitmap : Bitmap = new Bitmap(bitmapData);
	var jpg:JPEGEncoder = new JPEGEncoder(100);
	var ba:ByteArray = jpg.encode(bitmapData);
	file.save(ba,"Chart" + '.png');
}

/**
 * Generate High quality pdf
 */
private function generatePDFOK ():void
{
myPDF = new PDF(  Orientation.LANDSCAPE );
myPDF.setDisplayMode ( Display.FULL_PAGE ); 
myPDF.addPage();

var mc:MovieClip= new MovieClip();
//mc.addChild(p2);

var scale:Number = 0.5;
var matrix:Matrix = new Matrix();
matrix.scale(scale, scale);

var bitmapData:BitmapData = new BitmapData(p4.width* scale, p4.height* scale);
bitmapData.draw(p4, matrix, null, null, null, true);


//var image:ImageSnapshot = ImageSnapshot.captureImage(p4, 300, new JPEGEncoder())
//var images:ImageSnapshot = ImageSnapshot.captureImage(p2, 300, new JPEGEncoder());

var bitmap : Bitmap = new Bitmap(bitmapData);
var encoder:JPEGEncoder=new JPEGEncoder(100);
var stream:ByteArray = encoder.encode(bitmapData);
//myPDF.addImageStream(image.data, ColorSpace.DEVICE_RGB);
myPDF.addImageStream(stream, ColorSpace.DEVICE_RGB);
myPDF.save( Method.REMOTE, "http://130.239.131.199/createpdf.php", "geneplot.pdf" );


}

private function doPrint(whatToPrint:UIComponent):void{
	var printPDF:PDF = new PDF( Orientation.LANDSCAPE, Unit.MM, Size.A4 );
	printPDF.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE );
	printPDF.addPage();
	//printPDF.addImage( whatToPrint 0, 0, 0, 0, 'PNG', 100, 1,true );
	printPDF.save( Method.REMOTE, "http://130.239.131.199/createpdf.php", "test.pdf" );
}


import mx.printing.FlexPrintJobScaleType;
import mx.printing.FlexPrintJob;
import utils.DataGridUtils;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

private function printChart():void
{
	var fpj:FlexPrintJob = new FlexPrintJob();
	if (fpj.start())
	{
		fpj.addObject(p4,FlexPrintJobScaleType.MATCH_WIDTH);
		fpj.send();
	}
}
/**
 * Handle failed HTTPService component requests.
 */
private function expressionDataResultFault(event:FaultEvent):Boolean {
	Alert.show("Fault");
//	changeStatus("There was an error loading webservice data, please try again.");
	return true;
}
/**
 * Chart change Label style.
 */

private function changename(item:Object, prevValue:Object, axis:CategoryAxis, categoryItem:Object):String {
	var pattern:RegExp = /_/gi;
	var str1:String=new String();
	str1=item.replace(pattern, " ");
	return str1;
	
}

private function showalltips():void{
	
	if(showallchk.selected){
		myChartLine.showAllDataTips=true;
		myChartPlot.showAllDataTips=true;
		myChartBar.showAllDataTips=true;
		myChartColumn.showAllDataTips=true;
		myChartArea.showAllDataTips=true;
		if(trechart.selected){
		CreateTree();
		myChartTree.labelPolicy="all";
		}
	}else{
		myChartLine.showAllDataTips=false;
		myChartPlot.showAllDataTips=false;
		myChartBar.showAllDataTips=false;
		myChartColumn.showAllDataTips=false;
		myChartArea.showAllDataTips=false;
		if(trechart.selected){
			CreateTree();
			myChartTree.labelPolicy="";
		}
	}
	//onClickbutton();
}
private function helpGo():void {
	
	var URL:String = "http://v22.popgenie.org/explotService/help.html" ;
	navigateToURL(new URLRequest(URL), "_blank");
}

/**
 * export grid data as CSV
 */

private function handleExportClick():void{
/*	var ac:ArrayCollection = new ArrayCollection(tempadg.columns);
	var dgc:AdvancedDataGridColumn = new AdvancedDataGridColumn();
	
	dgc.dataField = "id"; 
	dgc.headerText = "ID"; 

	dgc.dataField = "data"; 
	dgc.headerText = "Data"; 

	dgc.dataField = "label"; 
	dgc.headerText = "Lebal"; 
	
	
	ac.addItem(dgc);
	tempadg.columns = ac.toArray();	
	*/
	tempadg.dataProvider=tmpArray;
	DataGridUtils.loadDataGridInExcel(tempadg);
}

/**
 * Retrieves the crossdomain file for the web-service policy file.
 */
private function loadPolFile(url:String):void {
	Security.loadPolicyFile(url);
}
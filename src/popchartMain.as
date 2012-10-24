import com.adobe.serialization.json.JSON;
import com.amcharts.AmLegend;
import com.amcharts.AmLegend__switchV;
import com.amcharts.AmSerialChart;
import com.amcharts.axes.CategoryAxis;
import com.amcharts.axes.Guide;
import com.amcharts.axes.ValueAxis;
import com.amcharts.chartClasses.AmGraph;
import com.amcharts.chartClasses.ChartCursor;
import com.amcharts.chartClasses.ChartScrollbar;
import com.amcharts.events.AmChartEvent;
import com.amcharts.events.GraphEvent;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.effects.easing.Sine;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

import spark.effects.animation.Animation;

[Bindable]
private var modelConfig:Object;
[Bindable]
private var modelPartList:ArrayCollection=new ArrayCollection();
[Bindable]
private var tmpArray:ArrayCollection=new ArrayCollection();

private var signalError:Boolean;
[Bindable]
private var poptrid:String;
[Bindable]
private var aTemp:Array= new Array();
[Bindable]
private var amgraph:AmGraph = new AmGraph();
[Bindable]
private var valuaxis:ValueAxis = new ValueAxis();
[Bindable]
private var legendVisible:Boolean;
[Bindable]
private var cantfind:String="";
[Bindable]
private var charttypeString:String="line";
[Bindable]
private var showballoonBoolean:Boolean=false;
[Bindable]
private var roundbulletBoolean:Boolean=false;
[Bindable]
private var amserialchart:AmSerialChart=new AmSerialChart();
[Bindable]
private var catergoryaxis:CategoryAxis=new CategoryAxis();
[Bindable]
private var amlegend:AmLegend=new AmLegend();
[Bindable]
private var chartscrollbar:ChartScrollbar=new ChartScrollbar();
[Bindable]
private var chartcursor:ChartCursor=new ChartCursor();
[Bindable]
private var numberofgenes:String=new String();
[Bindable]
private var flagged:Boolean=false;
[Bindable]
private var tempgridarryColl:ArrayCollection=new ArrayCollection();
[Bindable]
private var effect:Function = Sine.easeIn;
[Bindable]
private var dp:ArrayCollection=new ArrayCollection();

[Bindable]
private var categoryaxisstring:String="gsm_desc";

private function eplant_init2() : void {
	serve_getConfigData.send();
}



private function addChart():void {
	modelPartList=new ArrayCollection();
	tmpArray=new ArrayCollection();
	dp=new ArrayCollection();
	main.removeAllElements();
	mainres.removeAllElements();
	cantfind="";


	amserialchart=new AmSerialChart();
	catergoryaxis=new CategoryAxis();
	chartscrollbar=new ChartScrollbar();

	valuaxis=new ValueAxis();
	valuaxis.title="Log2 Expression value";

	//amserialchart.setStyle("startEffect",effect);
	//amserialchart.setStyle("duration",1);
	amserialchart.addValueAxis(valuaxis);
	
	amlegend=new AmLegend();
	amlegend.percentWidth=100;
	amlegend.x=0;
	amlegend.setStyle("reversedOrder","true");
	amlegend.setStyle("switchType","v");
	amlegend.setStyle("markerType","circle");
	amlegend.setStyle("marginLeft","0");
	amlegend.setStyle("marginRight","0");
	amlegend.setStyle("align","center");
	amlegend.setStyle("rollOverGraphAlpha","0.1");

	
	
	
	amlegend.dataProvider=amserialchart;
	mainres.addElement(amlegend);
	amserialchart.addEventListener(AmChartEvent.DATA_UPDATED,mainchartDataUpdated);
	
	main.addElement(amserialchart);
	legendVisible=true;
	
	dataSend();
	flagged=true;
}


private function dataSend():void{
	numberofgenes="";
	
	var str:String =inputtxt.text;//"POPTR_0001s00480,POPTR_0001s00410,POPTR_0001s00390";
	var pattern:RegExp = /,/gi;
	var a:Array = str.replace(pattern, " ").split(/\s+/);
	a.sort(Array.DESCENDING);
	//a.refresh();
	//Alert.show(a.toString());
	numberofgenes=a.length.toString();
	if(a.length<51){
	for(var h:int=0;h<a.length;h++){
		if(!explotrb.selected){
		var base:String = modelConfig.settings.url+"?primaryGene="+a[h]+"&type=line";//	serve_getTranscriptData.url =modelConfig.settings.url+"?id="+a[h];
		}else{
		base = modelConfig.settings.urlsecond+"?primaryGene="+a[h]+"&type=line";	
		}
		serve_getExpressionData.url = base ;
		
		serve_getExpressionData.send();
	}
	}else{
		Alert.show("You can't view more than 50 genes here","Over limit!")
		legendVisible=false;
	}
	
	quickchangexaxis=false;
} 


private function handle_config_files(event:ResultEvent):void {
	modelConfig = (JSON.decode(String(event.result)));
	loadPolFile(modelConfig.settings.policy_file);
	creationcompleteflashVars();
}

private function creationcompleteflashVars():void{
if(FlexGlobals.topLevelApplication.parameters.id!=null){
	if(FlexGlobals.topLevelApplication.parameters.id.toString().length>3){
		var pattern:RegExp = /,/gi;
		FlexGlobals.topLevelApplication.parameters.id=FlexGlobals.topLevelApplication.parameters.id.replace(pattern, ",  ")
		inputtxt.text=FlexGlobals.topLevelApplication.parameters.id.toString();
		if(FlexGlobals.topLevelApplication.parameters.type!=null){
			categoryaxisstring="experiment";
			changeaxis.selectedIndex=1;
		}
		
		addChart();
	}else{
		//
	}
	}
}
	
/**
 * Retrieves the crossdomain file for the web-service policy file.
 */
private function loadPolFile(url:String):void {
	Security.loadPolicyFile(url);
}
/**
 * Handle failed HTTPService component requests.
 */
private function expressionDataResultFault(event:FaultEvent):Boolean {
	Alert.show("Fault");
	return true;
}

/**
 *  Retrieve the expression data results from the web service handler.
 */
private function expressionDataResult(event:ResultEvent):Boolean {
	if (signalError) {
		Alert.show("SE");
		return false; }
	var exprData:Object = JSON.decode(String(event.result));
	
	if (exprData["error"] == undefined) {
		poptrid = new String(exprData['poptr']);
		
		// A loop is used in case a future script will provide more sample details to record
		for (var name:String in exprData['signals']) {
			var numberValue:Number = new Number(exprData['signals'][name]['value']);
			//var numberValueex:Number = new Number(exprData['signals'][name]['exp_id']);
			var numberValuek1:Number = new Number(exprData['signals'][name]['valuek1']);
			var numberValuek2:Number = new Number(exprData['signals'][name]['valuek2']);
			var numberValuek3:Number = new Number(exprData['signals'][name]['valuek3']);
			var numberValuek5:Number = new Number(exprData['signals'][name]['valuek5']);
			var numberValuek9:Number = new Number(exprData['signals'][name]['valuek9']);
			
			var popid:String = new String(exprData['signals'][name]['id']);
			var expid:String = new String(exprData['signals'][name]['exp_id']);
			
			var gsm_info:String = new String(exprData['signals'][name]['gsm_info']);
			var gsm_desc:String = new String(exprData['signals'][name]['gsm_desc']);
			var gse_desc:String = new String(exprData['signals'][name]['gse_desc']);
		
			
			if(quickchangexaxis==true){
			
			
			aTemp.push({id:poptrid,data:numberFormatter.format(numberValue),exp_id:expid,label:gsm_info,gsm_info:popid,gsm_desc:gsm_desc,gse_desc:gse_desc});
			tmpArray.addItem({id:poptrid,data:numberFormatter.format(numberValue),exp_id:expid,label:gsm_info,gsm_info:popid,gsm_desc:gsm_desc,gse_desc:gse_desc});				
		
			}else{
				aTemp.push({id:poptrid,data:numberFormatter.format(numberValue),exp_id:expid,label:popid,gsm_info:gsm_info,gsm_desc:gsm_desc,gse_desc:gse_desc});
				tmpArray.addItem({id:poptrid,data:numberFormatter.format(numberValue),exp_id:expid,label:popid,gsm_info:gsm_info,gsm_desc:gsm_desc,gse_desc:gse_desc});				
	
				
			}
			
			}
		
		
		
	}
	if(exprData['signals']!=null){
		sortCollection(tmpArray);
		modelPartList=new ArrayCollection(aTemp);
		modelPartList.refresh();
		sortCollection(modelPartList);
			
		amgraph = new AmGraph()
			
		amgraph.dataProvider=modelPartList;
		amgraph.title=poptrid;//getRandomNumber().toString();
		amgraph.valueField ="data";
		amgraph.descriptionField="exp_id"
			
		if(quickchangexaxis==true){
		amgraph.balloonText="Expression value: [[value]]\nSample Id: [[gsm_info]] \nExperiment id: [[description]] \nGSM Desc:[[gsm_desc]] \nGSE Desc:[[gse_desc]] \nGSM Info:[[label]] \nGene Id: <a href='http://popgenie.org/"+poptrid+"'>"+poptrid+"</a> ";
		}else{
		amgraph.balloonText="Expression value: [[value]]\nSample Id: [[label]] \nExperiment id: [[description]] \nGSM Desc:[[gsm_desc]] \nGSE Desc:[[gse_desc]] \nGSM Info:[[gsm_info]] \nGene Id: <a href='http://popgenie.org/"+poptrid+"'>"+poptrid+"</a> ";
				
		}
		
		amgraph.type = charttypeString;
		amgraph.setStyle("fontFamily","localVerdana");
		if(bullededgeChk.selected){
			amgraph.setStyle("bullet","round");
		}
		if(showballonsChk.selected){
			amgraph.showBalloon=false;
		}
		amgraph.setStyle("lineThickness","2");
		if(parseInt(numberofgenes)>20 && parseInt(numberofgenes)< 51){
		amgraph.setStyle("lineColor","0x606060");
		}
		amserialchart.addGraph(amgraph);
		
		finalcall();
		populatedatagrid();
		aTemp=new Array();
	}else{
		cantfind+=poptrid.toString()+'\n';
	}
	
	return true;
}

/*private function mainchartDataUpdated():void{
	addguides();
}*/
[Bindable]
private var quickchangexaxis:Boolean=false;

private function mainchartDataUpdated(evt:AmChartEvent):void{
	if(flagged==true){
	for(var i:int=0;i<modelPartList.length-1;i++){
	if(ObjectUtil.compare(modelPartList[i].exp_id,modelPartList[i+1].exp_id)!=false){
		var aGuide:Guide = new Guide();
		aGuide.category = modelPartList[i].label.toString();
		
		
		
		
		switch(categoryaxisstring)
		{
			case "sample":
			{
				aGuide.label=' '+modelPartList[i].exp_id.toString()+' \n\n\n';
				aGuide.inside=true;
				aGuide.labelRotation=90;
				catergoryaxis.title="Samples with experiment guidlines";
				catergoryaxis.setStyle("labelsEnabled",true);
				catergoryaxis.setStyle("labelRotation","45");	
				break;	
			}
			case "experiment":
			{
				aGuide.label='\n\n\n\n\n'+modelPartList[i].exp_id.toString()+' \n\n\n\n\n\n';
				aGuide.inside=false;
				aGuide.labelRotation=0.1;
				catergoryaxis.title="Experiments";
				catergoryaxis.setStyle("labelsEnabled",false);				
				
				break;	
			}
			case "gsm_desc":
			{
				aGuide.label=' '+modelPartList[i].gsm_desc.toString()+' \n\n\n';
				aGuide.inside=true;
				
				aGuide.labelRotation=90;
				catergoryaxis.title="Samples with sample description guidlines";
				catergoryaxis.setStyle("labelsEnabled",true);
				catergoryaxis.setStyle("labelRotation","45");			
				
				break;	
			}
			case "gse_desc":
			{
				aGuide.label=' '+modelPartList[i].gse_desc.toString()+' \n\n\n';
				aGuide.inside=true;
				aGuide.labelRotation=90;
				catergoryaxis.title="Samples with experiment description guidlines";
				catergoryaxis.setStyle("labelsEnabled",true);
				catergoryaxis.setStyle("labelRotation","45");			
				
				break;	
			}	
			case "gsm_info":
			{
				quickchangexaxis=true;
				aGuide.label=' '+modelPartList[i].exp_id.toString()+' \n\n\n';
				aGuide.inside=true;
				aGuide.labelRotation=90;
				catergoryaxis.title="Samples information";
				catergoryaxis.setStyle("labelsEnabled",true);
				catergoryaxis.setStyle("labelRotation","45");			
				//amserialchart.validateDisplayList();
				break;	
			}
				
			default :
			{
				aGuide.label=' '+modelPartList[i].exp_id.toString()+' \n\n\n';
				aGuide.inside=true;
				aGuide.labelRotation=90;
				catergoryaxis.title="Samples with experiment guidlines";
				catergoryaxis.setStyle("labelsEnabled",true);
				catergoryaxis.setStyle("labelRotation","45");
				break;
			}
				
		}
		
		
		
		
		aGuide.dashLength=10; 
		aGuide.lineColor=0xFF0000;
		aGuide.lineThickness=1.6;	
		aGuide.lineAlpha=0.6;
		catergoryaxis.addGuide(aGuide);	
		
		catergoryaxis.setStyle("gridAlpha","0.2");
		
		//catergoryaxis.parseDates=false;
		//catergoryaxis.equalSpacing=false;
	
		
		
		catergoryaxis.gridPosition="middle"; /***///start when its start it will middle grid
		catergoryaxis.setStyle("gridCount",20);
		amserialchart.categoryAxis=catergoryaxis; 
		
	
	}
	}
	flagged=false;
	}
}

private function finalcall2():void{
	amgraph.showBalloon=true;
	amgraph.showBalloon=true;
	amgraph.showBalloon=true;
	
	amgraph.showAllValueLabels=true;
	amserialchart.validateProperties();
}




private function finalcall():void{
	catergoryaxis=new CategoryAxis();
	chartscrollbar=new ChartScrollbar();
	amserialchart.dataProvider=modelPartList;
	
	chartscrollbar.y=10;
	chartscrollbar.height=20; 
	chartscrollbar.visible=true;
	chartscrollbar.graph=amgraph; 

	amserialchart.chartScrollbar=chartscrollbar;
	amserialchart.categoryField="label";
//	if(redirectedfrompopnet==true){
	//amserialchart.categoryAxis.labelFunction=buttonBar_labelFunc;//david
//	}
	
	amserialchart.percentHeight=100;
	//maincursor.crosshair=true; 
	chartcursor.oneBalloonOnly=true;
	chartcursor.cursorPosition = "middle";
	 
	amserialchart.chartCursor=chartcursor;
	amserialchart.percentWidth=100;
	amserialchart.validateNow();
} 
/*private function buttonBar_labelFuncs(item:Object):String {
	return "";//david
}*/


import mx.events.SliderEvent;
import mx.controls.sliderClasses.Slider;
import flash.events.Event;
import spark.components.RadioButtonGroup;
import flash.display.BitmapData;
import mx.graphics.codec.PNGEncoder;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import components.additionaltoolboxpopup;
import mx.controls.ComboBox;



private function cataxisChange(event:SliderEvent):void{
	var ct:Slider=Slider(event.currentTarget);
	catergoryaxis.setStyle("gridCount",ct.value);
	amserialchart.validateNow();
}


private function sliderChangeTwo(event:SliderEvent):void {
	var ct:Slider=Slider(event.currentTarget);
	valuaxis.min=ct.values[0];
	valuaxis.max=ct.values[1];

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

private function radiochangecharttype():void{
	if(linerb.selected){
		charttypeString="line";
	}else if(smoothlinerb.selected){
		charttypeString="smoothedLine";
	}else if(columnrb.selected){
		charttypeString="column";
	//}else if(steprb.selected) {
	//	charttypeString="step";
	}else{
		
	}
	addChart();
	//amserialchart.chartType=charttypeString;
	//amserialchart.removeGraph(
	//amserialchart=new AmSerialChart();
	//amgraph.type=charttypeString;
	
	
//amserialchart.invalidateDisplayList()();
}	

// Save as image //////////////////////////
private function saveAsImage():void
{
	var pngSource:BitmapData = new BitmapData (bigmain.width, bigmain.height);
	pngSource.draw(bigmain);
	
	var pngEncoder:PNGEncoder = new mx.graphics.codec.PNGEncoder();
	var pngData:ByteArray = pngEncoder.encode(pngSource);
	
	var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
	var uRLRequest:URLRequest = new URLRequest("http://v22.popgenie.org/explotService/saveAsImage.php?name=chart.png");
	uRLRequest.requestHeaders.push(header);
	uRLRequest.method = URLRequestMethod.POST;
	uRLRequest.data = pngData;
	navigateToURL(uRLRequest);
}

// Context menu ///////////////////////////
[Bindable]
private var cm:ContextMenu;

private function initContextMenu():void
{
	var cmi:ContextMenuItem = new ContextMenuItem("Export as image", true);
	cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, contextMenuEventHandler);
	
	cm = new ContextMenu();
	cm.customItems.push(cmi);
	cm.hideBuiltInItems();
}

private function contextMenuEventHandler(event:ContextMenuEvent):void
{
	saveAsImage();
}
private function helpGo():void {
	
	var URL:String = "http://www.popgenie.org/book/explot" ;
	navigateToURL(new URLRequest(URL), "_blank");
}


private function populatedatagrid():void{
	
	var i:int=0;
	var id:Object=new Object();
	var label:Object=new Object();
	var data:Object=new Object();
	var columns:Array = new Array();

	//Alert.show(modelPartList.toString());
	
	
	data["ID"]=modelPartList[0].id;;
	var advancedDataGridColumn2:AdvancedDataGridColumn=new AdvancedDataGridColumn();  
	advancedDataGridColumn2.dataField="ID";
	columns.push(advancedDataGridColumn2);
	
	
	for (i=0; i < modelPartList.length; i++)
	{
		id[modelPartList[i].label]=modelPartList[i].id;
		label[modelPartList[i].label]=modelPartList[i].label;
		data[modelPartList[i].label]=modelPartList[i].data;
		var advancedDataGridColumn:AdvancedDataGridColumn=new AdvancedDataGridColumn();         
		advancedDataGridColumn.dataField=modelPartList[i].label;
		columns.push(advancedDataGridColumn);
	
	}
	
	//data[modelPartList[0].label]="test";
//	dp.addItemAt(,0);
//	dp.addItem({id:modelPartList[0].id,label:data});
	//dp.source.push(modelPartList[0].id);
	dp.addItem(data);
//	dp.addItem({id:id,label:data});
	//dp.addItem({poptrid:poptrid,label:data});
	adg1.columns=columns;
	adg1.invalidateDisplayList();
	
	
}
/*Category axis variable change*/
private function categoryaxisvariablechange(evt:Event):void{
	var group:ComboBox = evt.currentTarget as ComboBox;
	switch(group.selectedItem.data)
	{
		case "sample":
		{
			categoryaxisstring="sample";
			break;	
		}
		case "experiment":
		{
			categoryaxisstring="experiment";
			break;	
		}
		case "gsm_desc":
		{
			categoryaxisstring="gsm_desc";
			break;	
		}
		case "gse_desc":
		{
			categoryaxisstring="gse_desc";
			break;	
		}	
		case "gsm_info":
		{
			
			categoryaxisstring="gsm_info";
			break;	
		}	
			
		default :
		{
			categoryaxisstring="sample";
			break;
		}

}
	
	addChart();
}
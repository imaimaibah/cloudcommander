/*
VERSION 1.0
*/
var _lf = 0;

//Transer to the url
function forward(url){
	location.href = url;
}

//Even number
//True: even number
//False: odd number
function isEven(someNumber){
    return (someNumber%2 == 0) ? true : false;
}

function downloader(file) {
	if(file == 'Auth failed'){
		alert(file);
		return;
	}
//	top.location = "/cgi-bin/downloader.cgi?target=" + file;
//	var JSON = $.ajax({
//		"type": "GET",
//		"url": "/cgi-bin/downloader.cgi?download=" + file,
//		"data": null,
//		"dataType": "json",
//		"contentType": "application/json",
//		complete: function(obj){
//			if(obj['status'] === 200){
				window.location.href="/cgi-bin/downloader.cgi?download="+file;
				window.location.target="_blank";
//			}
//		},
//		error: function(obj){
//			alert(obj.responseText);
//		},
//		"async": false
//	}).responseText;

//return JSON;
}

function sendReceiveJSON(method,url,option,obj,id){
	$("#loading", window.parent.document).show();
//	_lf++;
	var JSON = $.ajax({
    	"type": method,
    	"url": url,
			"data": option,
    	"dataType": "json",
			"contentType": "application/json",
			"success" : function(data){
/*
				if(_lf == 1){
					$("#loading", window.parent.document).hide();
					_lf--;
				}else{
					_lf--;
				}
*/
				obj(data,id);
			},
			"complete" : function(){
					$("#loading", window.parent.document).hide();
			},
    	"async": true
	}).responseText;
 
}

function sendReceiveTXT(method,url,option,obj,id){
	$("#loading", window.parent.document).show();
	_lf++;
	var TXT = $.ajax({
    	"type": method,
    	"url": url,
			"data": option,
    	"dataType": "text",
			"contentType": "text/plain",
			"success" : function(data){
				if(_lf == 1){
					$("#loading", window.parent.document).hide();
					_lf--;
				}else{
					_lf--;
				}
				obj(data,id);
			},
    	"async": true
	}).responseText;

}

function IslandList(json,id){
  if(json.result == "Auth failed"){
    alert(json.result);
    return;
  }
	var div = document.getElementById(id);
	var txt = "<select id='islandList' style='width:150px' name='islandList'>";
	txt += "<option id='region' value='region'>Region</option>";

	for(i in json.island){
		txt += "<option id='"+json.island[i]+"' value='"+json.island[i]+"'>"+json.island[i]+"</option>";
	}
	txt += "</select> ";
	txt += "<button onClick='getResources();'>Select</button>";
	div.innerHTML = txt;
}

var addEvent = (window.addEventListener) ?
   (function(elm, type, event) {
      elm.addEventListener(type, event, false);
   }) : (window.attachEvent) ?
   (function(elm, type, event) {
      elm.attachEvent('on'+type, event);
   }) :
   (function(elm, type, event) {
      elm['on'+type] = event;
   }) ;

var Position = {
   offset: function(elm) {
      var pos = {};
      pos.x = this.getOffset('Left', elm);
      pos.y = this.getOffset('Top', elm);
      return pos;
   },

   getOffset: function(prop, el) {
      if(!el.offsetParent || el.offsetParent.tagName.toLowerCase() == "body")
         return el['offset'+prop];
      else
         return el['offset'+prop]+ this.getOffset(prop, el.offsetParent);
   }
};

function CountArrayElements(array){
	var cnt = 0;
	for(key in array){ cnt++; }
	return cnt;
}

function setsessionStorage(data,id){
	sessionStorage.setItem(id,JSON.stringify(data));
}

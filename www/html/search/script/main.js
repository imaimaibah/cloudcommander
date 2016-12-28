function forward(url){
	location.href = url;
}

function sendReceiveJSON(method,url,option){
	// JSON POST送信・取得
	var JSON = $.ajax({
    	"type": method,
    	"url": url,
			"data": option,
    	"dataType": "json",
    	"async": false
	}).responseText;
 
return JSON;
}

function sendReceiveTXT(method,url,option){
	var TXT = $.ajax({
    	"type": methot,
    	"url": url,
			"data": option,
    	"dataType": "text",
    	"async": false 
	}).responseText;
 
return TXT;
}

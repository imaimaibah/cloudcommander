function sendReceiveJSON(method,url,option){
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
		"type": method,
		"url": url,
		"data": option,
		"dataType": "text",
		"async": false
	}).responseText;

return TXT;
}

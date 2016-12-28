var xmlhttp = false;

if(typeof ActiveXObject != "undefined"){
	try {
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	} catch (e) {
		xmlhttp = false;
	}
}

if(!xmlhttp && typeof XMLHttpRequest != "undefined"){
	xmlhttp = new XMLHttpRequest();
}

function sendReceive(method,url,param){
//	xmlhttp.onreadystatechange = func;
	xmlhttp.open(method,url,false);
	xmlhttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	//xmlhttp.setRequestHeader("Authorization","Basic c29wdXNlcjptdG0hMDI1Ng==");
	xmlhttp.send(param);
	return xmlhttp.responseText;
}

function sendReceiveXML(method, url, param){
	xmlhttp.open(method, url, false);
	xmlhttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	//xmlhttp.setRequestHeader("Authorization","Basic c29wdXNlcjptdG0hMDI1Ng==");
	xmlhttp.send(param);
	return xmlhttp.responseXML.documentElement;
}

function sendReceiveXMLbyXML(method,url,param){
	xmlhttp.open(method,url,false);
	xmlhttp.setRequestHeader("Content-Type","application/xml");
	//xmlhttp.setRequestHeader("Authorization","Basic c29wdXNlcjptdG0hMDI1Ng==");
	xmlhttp.send(param);
	return xmlhttp.responseXML.documentElement;
}

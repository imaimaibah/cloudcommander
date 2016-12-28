//// GET PARAMETERS ////
function getParameters() {
	var parameters = new Array();
	var query = window.location.search.substring(1);
	var parms = query.split('&');
	for (var i=0; i<parms.length; i++) {
		var pos = parms[i].indexOf('=');
		if (pos > 0) {
			var key = parms[i].substring(0, pos);
			var val = parms[i].substring(pos + 1);
			parameters[key] = val;
		}
	}
	return parameters;
}

//// JUDGE DEFAULT TEMPLATE ////
function isDefault(templateId){
	if("DEFAULT" == templateId){
		return true;
	}
	return false;
}

//// GET REQUEST-XML OF ATTACH/DETACH API ////
function getRequestQuotaXml(userId, templateId, orgs){
	var ret = "";
	ret += "<Request>";
	ret += "	<userId>" + userId + "</userId>";
	ret += "	<templateId>" + templateId + "</templateId>";
	ret += "	<orgIds>";
	for(var i = 0; i < orgs.length; i++){
		ret += "		<id>" + orgs[i] + "</id>";
	}
	ret += "	</orgIds>";
	ret += "</Request>";
	return ret;
}

//// GET X-PATH CONTENT ////
function XPathContent(obj,path,nullContent){
	var elem = document.evaluate(path,obj,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null);
	if(elem != null){
		try{
			if(elem.singleNodeValue.textContent != null){
				return elem.singleNodeValue.textContent;
			}else{
				if(nullContent != null) return nullContent;
				return null;
			}
		}catch(e){
			if(nullContent != null) return nullContent;
			return null;
		}
	}
	if(nullContent != null) return nullContent;
	return null;
}

//// GET X-PATH ELEMENT ////
function XPathElem(obj,path,nullContent){
	var elem = document.evaluate(path,obj,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null);
	if(elem != null) return elem.singleNodeValue;
	return null;
}

//// GET X-PATH LIST ////
function XPathList(obj,path,nullContent){
	var elem = document.evaluate(path,obj,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE ,null);
	if(elem != null) return elem;
	if(nullContent != null) return nullContent;
	return null;
}

//// ADJUST HEIGHT ////
function adjustHeight(obj){
	obj.style.height =getBrowserHeight() + "px";
	var wHeight = getBrowserHeight();
	var wInrHeight = getBrowserInnerHeight();
	var listHeight = obj.clientHeight;
	var objHeight = (obj.clientHeight - (wHeight - wInrHeight));
	if(objHeight < 100) objHeight = 100;
	obj.style.height = objHeight + "px";
}

//// GET OBJECT ////
function $(id){
	return document.getElementById(id);
}

//// GET BROWSER HEIGHT (INNER) ////
function getBrowserInnerHeight() {
        if ( window.innerHeight ) {
                return window.innerHeight;
        }
        else if ( document.documentElement && document.documentElement.clientHeight != 0 ) {
                return document.documentElement.clientHeight;
        }
        else if ( document.body ) {
                return document.body.clientHeight;
        }
        return 0;
}

//// GET BROWSER WIDTH (INNER) ////
function getBrowserInnerWidth() {
        if ( window.innerWidth ) {
                return window.innerWidth;
        }
        else if ( document.documentElement && document.documentElement.clientWidth != 0 ) {
                return document.documentElement.clientWidth;
        }
        else if ( document.body ) {
                return document.body.clientWidth;
        }
        return 0;
}

//// GET BROWSER HEIGHT ////
function getBrowserHeight() {
	return Math.max.apply( null, [document.body.clientHeight , document.body.scrollHeight, document.documentElement.scrollHeight, document.documentElement.clientHeight] );   

}

//// ESCAPE ////
function escapeHTML(str) {
  return str.replace(/[&"<>]/g, function(c) {
    return {
      "&": "&amp;",
      '"': "&quot;",
      "<": "&lt;",
      ">": "&gt;"
    }[c];
  });
}

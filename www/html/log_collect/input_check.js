function input_check_vsysId(){
  var val = $("#vsys-db_vsysId");
//  alert(val.val());
  if (jsTrim(val.val()).length == 0){
    alert("Please input vsys-ID.");
    return;
  }

  if (!val.val().match(/[a-zA-Z0-9]{8}-[a-zA-Z0-9]{9}/)){
    alert("Please check that input value is correct");
    return;
  }
  log_collect(21);
}

function input_check_hizuke(type){
  if(type == 'ap'){
    var inputVal = $("#vsys-ap_hizuke");
  } else if (type = 'db'){
    var inputVal = $("#vsys-db_hizuke");
  }
  var todayDate = new Date();
  var todayYear = todayDate.getFullYear();
  var todayMonth = todayDate.getMonth() + 1;
  var todayDay = todayDate.getDate();

  var today = todayYear * 10000 + todayMonth * 100 + todayDay;

  var lastMonth = new Date();
  lastMonth.setDate(0);
  var lastMonthYear = String(lastMonth.getFullYear());
  var lastMonthMonth = String(100 + lastMonth.getMonth() + 1).substr(1,2);
  var lastMonth1stDay = lastMonthYear * 10000 + lastMonthMonth * 100 + 1;

  if (jsTrim(inputVal.val()).length == 0){
    alert("Please check that input date is correct format.");
    return;
  }
  inputVal2 = inputVal.val().replace(/-/g,"");

  if ((inputVal2 > today) || (inputVal2 < lastMonth1stDay)){
    alert("Please select the target date b/w today and 1st of the last month");
    return;
  }

  if (type == 'ap'){
//    alert("take trace log on vsys-ap");
    log_collect(31);
  } else if (type == 'db'){
//    alert("take trace log on vsys-db");
    log_collect(22);
  }
}

function jsTrim(val){
  var ret = val;
  ret = ret.replace(/^[\s]*/,"");
  ret = ret.replace(/[\s]*$/,"");
  return ret;
}

function jsLTrim(val){
  var ret = val;
  ret = ret.replace(/^[\s]*/,"");
  return ret;
}

function jsRTrim(val){
  var ret = val;
  ret = ret.replace(/^[\s]*/,"");
  return ret;
}

function kvm_xen_check (){
	var select_dom0 = $("#Dom0_List option:selected").val();	
	var url = "/cgi-bin/log_collect/kvm-xen_check.cgi?dom0="+select_dom0; 
	sendReceiveTXT("GET",url,null,kvm_xen,null);
}

function kvm_xen(data,id){
	var txt = data;
	$("#kvm-xen").text(txt);
	if (txt.match(/XEN/)) {
		$("#kvm_take-bt1").attr("disabled",true);
		document.getElementById("kvm_dl1").style.display="none";
	} else if (txt.match(/KVM/)) {
		$("#xen_take-bt1").attr("disabled",true);
		document.getElementById("xen_dl1").style.display="none";
	} else {
		$("#xen_take-bt1").attr("disabled",true);
		$("#kvm_take-bt1").attr("disabled",true);
		$("#csm-agent-snap_take-bt1").attr("disabled",true);
	}
}

function input_check_Dom0_hostname(){
	var server = $("#pcl_server");
	if (jsTrim(server.val()).length == 0){
		alert("Please input the hostname.");
		return;
	}
	if (!server.val().match(/[a-z]{2}-[0-9]{2}-[0-9]{1}-ps[0-9]{4}-[0-9]{2}-[0-9]{2}/)){
		alert("Please check that input value is correct");
		return;
	}
	pcl_check();
}

function pcl_check(){
	var server = $("#pcl_server").val();
	var url = "/cgi-bin/log_collect/pcl_check.cgi?dom0="+server; 
	sendReceiveTXT("GET",url,null,pcl_server,null);
}

function pcl_server(data,id){
	var txt = data;
	$("#pcl-server").text(txt);
	if (txt.match(/0/)){
		$("#pcl_take-bt1").removeAttr("disabled");
		alert("This server has PCL.");
	} else if(txt.match(/2/)){
		$("#pcl_take-bt1").attr("disabled",true);
		alert("This server does not exists. Please check the input value.");
	} else {
		$("#pcl_take-bt1").attr("disabled",true);
		alert("This server does not have PCL. Please check the input value.");
	}
}


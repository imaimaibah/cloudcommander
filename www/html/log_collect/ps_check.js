function show_ror_csm_ps1(data,id){
	var island = $("#islandList option:selected").val();
	var txt = data;
	$("#ror-csm_ps1").text(txt);
	if (txt.match(/1a/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("ror-snap_dl1").style.display="block";
		document.getElementById("ror-snap_dl2").style.display="none";
		document.getElementById("csm-snap_dl1").style.display="none";
	} else if (txt.match(/2a/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("ror-snap_dl1").style.display="none";
		document.getElementById("ror-snap_dl2").style.display="block";
		document.getElementById("csm-snap_dl1").style.display="none";
	} else if (txt.match(/3a/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("ror-snap_dl1").style.display="none";
		document.getElementById("ror-snap_dl2").style.display="none";
		document.getElementById("csm-snap_dl1").style.display="block";
	} else {
		$("#ror-snap_take-bt1").removeAttr("disabled");
		$("#ror-snap_take-bt2").removeAttr("disabled");
		document.getElementById("ror-snap_dl1").style.display="none";
		document.getElementById("ror-snap_dl2").style.display="none";
		document.getElementById("csm-snap_dl1").style.display="none";

		if (island != "region") {
			$("#csm-snap_take-bt1").removeAttr("disabled");
		}	else {
			$("#csm-snap_take-bt1").attr("disabled",true);
		}
	}
}

function show_cnm_ps1(data,id){
  var txt = data;
  $("#cnm_ps1").text(txt);
  if (txt.match(/1b/)) {
		$("#cnm-snap_take-bt1").attr("disabled",true);
		$("#cnm-snap_take-bt2").attr("disabled",true);
		document.getElementById("cnm-snap_dl1").style.display="block";
		document.getElementById("cnm-snap_dl2").style.display="none";
  } else if (txt.match(/2b/)) {
		$("#cnm-snap_take-bt1").attr("disabled",true);
		$("#cnm-snap_take-bt2").attr("disabled",true);
		document.getElementById("cnm-snap_dl1").style.display="none";
		document.getElementById("cnm-snap_dl2").style.display="block";
  } else if (txt.match(/3b/)) {
		$("#cnm-snap_take-bt1").removeAttr("disabled");
		$("#cnm-snap_take-bt2").removeAttr("disabled");
		document.getElementById("cnm-snap_dl1").style.display="none";
		document.getElementById("cnm-snap_dl2").style.display="none";
	}
}
/*
function show_ror_snap_ps1(data,id){
	var island = $("#islandList option:selected").val();
	var txt = data;
	$("#ror-snap_ps1").text(txt);
	if (txt.match(/0/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("ror-snap_dl1").style.display="block";
	} else {
		$("#ror-snap_take-bt1").removeAttr("disabled");
		$("#ror-snap_take-bt2").removeAttr("disabled");
		document.getElementById("ror-snap_dl1").style.display="none";

		else {
			$("#csm-snap_take-bt1").attr("disabled",true);
		}
	}
}

function show_ror_snap_ps2(data,id){
	var island = $("#islandList option:selected").val();
	var txt = data;
	$("#ror-snap_ps2").text(txt);
	if (txt.match(/0/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("ror-snap_dl2").style.display="block";
	} else {
		$("#ror-snap_take-bt1").removeAttr("disabled");
		$("#ror-snap_take-bt2").removeAttr("disabled");
		document.getElementById("ror-snap_dl2").style.display="none";

		if (island != "region") {
			$("#csm-snap_take-bt1").removeAttr("disabled");
		} else {
			$("#csm-snap_take-bt1").attr("disabled",true);
		}
  }
}
*/
function show_ror_ope_ps1(data,id){
  var txt = data;
  $("#ror-ope_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#ror-ope_take-bt1").attr("disabled",true);
    document.getElementById("ror-ope_dl1").style.display="block";
  } else {
    $("#ror-ope_take-bt1").removeAttr("disabled");
    document.getElementById("ror-ope_dl1").style.display="none";
  }
}
/*
function show_cnm_snap_ps1(data,id){
  var txt = data;
  $("#cnm-snap_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#cnm-snap_take-bt1").attr("disabled",true);
    $("#cnm-snap_take-bt2").attr("disabled",true);
    document.getElementById("cnm-snap_dl1").style.display="block";
  } else {
    $("#cnm-snap_take-bt1").removeAttr("disabled");
    $("#cnm-snap_take-bt2").removeAttr("disabled");
    document.getElementById("cnm-snap_dl1").style.display="none";
  }
}

function show_cnm_snap_ps2(data,id){
  var txt = data;
	$("#cnm-snap_ps2").text(txt);
	if (txt.match(/0/)) {
		$("#cnm-snap_take-bt1").attr("disabled",true);
		$("#cnm-snap_take-bt2").attr("disabled",true);
		document.getElementById("cnm-snap_dl2").style.display="block";
	} else {
		$("#cnm-snap_take-bt1").removeAttr("disabled");
		$("#cnm-snap_take-bt2").removeAttr("disabled");
		document.getElementById("cnm-snap_dl2").style.display="none";
  }
}

function show_csm_snap_ps1(data,id){
  var txt = data;
  $("#csm-snap_ps1").text(txt);
  if (txt.match(/0/)) {
		$("#ror-snap_take-bt1").attr("disabled",true);
		$("#ror-snap_take-bt2").attr("disabled",true);
		$("#csm-snap_take-bt1").attr("disabled",true);
		document.getElementById("csm-snap_dl1").style.display="block";
	} else {
		$("#ror-snap_take-bt1").removeAttr("disabled");
		$("#ror-snap_take-bt2").removeAttr("disabled");
		$("#csm-snap_take-bt1").removeAttr("disabled");
		document.getElementById("csm-snap_dl1").style.display="none";
  }
}
*/
function show_VSYS_DB_ps1(data,id){
  var txt = data;
  $("#vsys-db_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#vsys-db_take-bt1").attr("disabled",true);
    document.getElementById("vsys-db_dl1").style.display="block";
  } else {
    $("#vsys-db_take-bt1").removeAttr("disabled");
    document.getElementById("vsys-db_dl1").style.display="none";
  }
}

function show_VSYS_DB_ps2(data,id){
  var txt = data;
  $("#vsys-db_ps2").text(txt);
  if (txt.match(/0/)) {
    $("#vsys-db_take-bt2").attr("disabled",true);
    document.getElementById("vsys-db_dl2").style.display="block";
  } else {
    $("#vsys-db_take-bt2").removeAttr("disabled");
    document.getElementById("vsys-db_dl2").style.display="none";
  }
}

function show_VSYS_AP_ps1(data,id){
  var txt = data;
  $("#vsys-ap_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#vsys-ap_take-bt1").attr("disabled",true);
    document.getElementById("vsys-ap_dl1").style.display="block";
  } else {
    $("#vsys-ap_take-bt1").removeAttr("disabled");
    document.getElementById("vsys-ap_dl1").style.display="none";
  }
}

function show_VSYS_AP_ps2(data,id){
  var txt = data;
  $("#vsys-ap_ps2").text(txt);
  if (txt.match(/0/)) {
    $("#vsys-ap_take-bt2").attr("disabled",true);
    document.getElementById("vsys-ap_dl2").style.display="block";
  } else {
    $("#vsys-ap_take-bt2").removeAttr("disabled");
    document.getElementById("vsys-ap_dl2").style.display="none";
  }
}

function show_charge_ps1(data,id){
  var txt = data;
  $("#charge_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#charge_take-bt1").attr("disabled",true);
    document.getElementById("charge_dl1").style.display="block";
  } else {
    $("#charge_take-bt1").removeAttr("disabled");
    document.getElementById("charge_dl1").style.display="none";
  }
}

function show_swcm_ps1(data,id){
  var txt = data;
  $("#swcm_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#swcm_take-bt1").attr("disabled",true);
    document.getElementById("swcm_dl1").style.display="block";
  } else {
    $("#swcm_take-bt1").removeAttr("disabled");
    document.getElementById("swcm_dl1").style.display="none";
  }
}

function show_swcm_ps2(data,id){
  var txt = data;
  $("#swcm_ps2").text(txt);
  if (txt.match(/0/)) {
    $("#swcm_take-bt2").attr("disabled",true);
    document.getElementById("swcm_dl2").style.display="block";
  } else {
    $("#swcm_take-bt2").removeAttr("disabled");
    document.getElementById("swcm_dl2").style.display="none";
  }
}

function show_swcm_ps3(data,id){
  var txt = data;
  $("#swcm_ps3").text(txt);
  if (txt.match(/0/)) {
    $("#swcm_take-bt3").attr("disabled",true);
    document.getElementById("swcm_dl3").style.display="block";
  } else {
    $("#swcm_take-bt3").removeAttr("disabled");
    document.getElementById("swcm_dl3").style.display="none";
  }
}

function show_xen_ps1(data,id){
  var txt = data;
  $("#xen_ps1").text(txt);
  if (txt.match(/0/)) {
    $("#xen_take-bt1").attr("disabled",true);
    document.getElementById("xen_dl1").style.display="block";
  } else {
    $("#xen_take-bt1").removeAttr("disabled");
    document.getElementById("xen_dl1").style.display="none";
  }
}

function show_csm_agent_snap_ps1(data,id){
	var txt = data;
	$("#csm-agent-snap_ps1").text(txt);
	if (txt.match(/0/)) {
		$("#csm-agent-snap_take-bt1").attr("disabled",true);
		document.getElementById("csm-agent-snap_dl1").style.display="block";
	} else {
		$("#csm-agent-snap_take-bt1").removeAttr("disabled");
		document.getElementById("csm-agent-snap_dl1").style.display="none";
	}
}

function show_kvm_ps1(data,id){
	var txt = data;
	$("#kvm_ps1").text(txt);
	if (txt.match(/0/)) {
		$("#kvm_take-bt1").attr("disabled",true);
		document.getElementById("kvm_dl1").style.display="block";
	} else {
		$("#kvm_take-bt1").removeAttr("disabled");
		document.getElementById("kvm_dl1").style.display="none";
	}
}

function show_pcl_ps1(data,id){
  var txt = data;
  $("#pcl_ps1").text(txt);
  if (txt.match(/0/)) {
//    $("#pcl_take-bt1").attr("disabled",true);
    document.getElementById("pcl_dl1").style.display="block";
  } else {
//    $("#pcl_take-bt1").removeAttr("disabled");
    document.getElementById("pcl_dl1").style.display="none";
  }
}

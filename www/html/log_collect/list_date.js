function list_date(sedai,opeType,island){

	var url_ps = "/cgi-bin/log_collect/list_ps_check.cgi?sedai="+sedai+"&ps_num="+opeType+"&island="+island;
	var url = "/cgi-bin/log_collect/list_date_check.cgi?sedai="+sedai+"&opeType="+opeType+"&island="+island;
	var url_param = "/cgi-bin/log_collect/list_param_check.cgi?sedai="+sedai+"&opeType="+opeType+"&dom0="+island;

	switch(opeType){
    case 11:
    case 12:
    case 16:
			sendReceiveTXT("GET",url_ps,null,show_ror_csm_ps1,null);
			break;
    case 14:
    case 15:
			sendReceiveTXT("GET",url_ps,null,show_cnm_ps1,null);
			break;
	}

	switch(opeType){
    case 11:
//			sendReceiveTXT("GET",url_ps,null,show_ror_snap_ps1,null);
			sendReceiveTXT("GET",url,null,show_ror_snap_Date1,null);
      break;

		case 12:
//			sendReceiveTXT("GET",url_ps,null,show_ror_snap_ps2,null);
			sendReceiveTXT("GET",url,null,show_ror_snap_Date2,null);
      break;

		case 13:
			sendReceiveTXT("GET",url_ps,null,show_ror_ope_ps1,null);
      sendReceiveTXT("GET",url,null,show_ror_ope_Date1,null);
      break;

    case 14:
//			sendReceiveTXT("GET",url_ps,null,show_cnm_snap_ps1,null);
      sendReceiveTXT("GET",url,null,show_cnm_snap_Date1,null);
      break;

		case 15:
//			sendReceiveTXT("GET",url_ps,null,show_cnm_snap_ps2,null);
      sendReceiveTXT("GET",url,null,show_cnm_snap_Date2,null);
      break;

    case 16:
//			sendReceiveTXT("GET",url_ps,null,show_csm_snap_ps1,null);
      sendReceiveTXT("GET",url,null,show_csm_snap_Date1,null);
      break;

    case 21:
			sendReceiveTXT("GET",url_ps,null,show_VSYS_DB_ps1,null);
      sendReceiveTXT("GET",url,null,show_VSYS_DB_Date1,null);
      sendReceiveTXT("GET",url_param,null,show_VSYS_DB_param1,null);
      break;

    case 22:
			sendReceiveTXT("GET",url_ps,null,show_VSYS_DB_ps2,null);
      sendReceiveTXT("GET",url,null,show_VSYS_DB_Date2,null);
      sendReceiveTXT("GET",url_param,null,show_VSYS_DB_param2,null);
      break;

    case 31:
			sendReceiveTXT("GET",url_ps,null,show_VSYS_AP_ps1,null);
      sendReceiveTXT("GET",url,null,show_VSYS_AP_Date1,null);
      sendReceiveTXT("GET",url_param,null,show_VSYS_AP_param1,null);
      break;

		case 32:
			sendReceiveTXT("GET",url_ps,null,show_VSYS_AP_ps2,null);
      sendReceiveTXT("GET",url,null,show_VSYS_AP_Date2,null);
      break;

    case 41:
			sendReceiveTXT("GET",url_ps,null,show_charge_ps1,null);
      sendReceiveTXT("GET",url,null,show_CHARGE_Date1,null);
      sendReceiveTXT("GET",url_param,null,show_charge_param1,null);
      break;

    case 51:
			sendReceiveTXT("GET",url_ps,null,show_swcm_ps1,null);
      sendReceiveTXT("GET",url,null,show_SWCM_Date1,null);
      break;

    case 52:
			sendReceiveTXT("GET",url_ps,null,show_swcm_ps2,null);
      sendReceiveTXT("GET",url,null,show_SWCM_Date2,null);
      break;

		case 53:
			sendReceiveTXT("GET",url_ps,null,show_swcm_ps3,null);
      sendReceiveTXT("GET",url,null,show_SWCM_Date3,null);
      sendReceiveTXT("GET",url_param,null,show_swcm_param3,null);
      break;

		case 61:
			sendReceiveTXT("GET",url_ps,null,show_xen_ps1,null);
			sendReceiveTXT("GET",url,null,show_XEN_Date1,null);
			sendReceiveTXT("GET",url_param,null,show_xen_param1,null);
			break;

		case 62:
			sendReceiveTXT("GET",url_ps,null,show_csm_agent_snap_ps1,null);
			sendReceiveTXT("GET",url,null,show_csm_agent_snap_Date1,null);
			sendReceiveTXT("GET",url_param,null,show_csm_agent_snap_param1,null);
			break;

    case 63:
      sendReceiveTXT("GET",url_ps,null,show_kvm_ps1,null);
      sendReceiveTXT("GET",url,null,show_KVM_Date1,null);
      sendReceiveTXT("GET",url_param,null,show_kvm_param1,null);
      break;

    case 71:
			sendReceiveTXT("GET",url_ps,null,show_pcl_ps1,null);
      sendReceiveTXT("GET",url,null,show_PCL_Date1,null);
      sendReceiveTXT("GET",url_param,null,show_pcl_param1,null);
      break;

    default:
      break;
  }
}

function show_ror_snap_Date1(data,id){
  var txt = data;
  $("#ror-snap_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#ror-snap_dl-bt1").attr("disabled",true);
    $("#ror-snap_del-bt1").attr("disabled",true);
  } else {
    $("#ror-snap_dl-bt1").removeAttr("disabled");
    $("#ror-snap_del-bt1").removeAttr("disabled");
  }
}

function show_ror_snap_Date2(data,id){
  var txt = data;
  $("#ror-snap_date2").text(txt);
  if (txt.match(/N\/A/)) {
    $("#ror-snap_dl-bt2").attr("disabled",true);
    $("#ror-snap_del-bt2").attr("disabled",true);
  } else {
    $("#ror-snap_dl-bt2").removeAttr("disabled");
    $("#ror-snap_del-bt2").removeAttr("disabled");
  }
}

function show_ror_ope_Date1(data,id){
  var txt = data;
  $("#ror-ope_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#ror-ope_dl-bt1").attr("disabled",true);
    $("#ror-ope_del-bt1").attr("disabled",true);
  } else {
    $("#ror-ope_dl-bt1").removeAttr("disabled");
    $("#ror-ope_del-bt1").removeAttr("disabled");
  }
}

function show_cnm_snap_Date1(data,id){
  var txt = data;
  $("#cnm-snap_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#cnm-snap_dl-bt1").attr("disabled",true);
    $("#cnm-snap_del-bt1").attr("disabled",true);
  } else {
    $("#cnm-snap_dl-bt1").removeAttr("disabled");
    $("#cnm-snap_del-bt1").removeAttr("disabled");
  }
}

function show_cnm_snap_Date2(data,id){
  var txt = data;
  $("#cnm-snap_date2").text(txt);
  if (txt.match(/N\/A/)) {
    $("#cnm-snap_dl-bt2").attr("disabled",true);
    $("#cnm-snap_del-bt2").attr("disabled",true);
  } else {
    $("#cnm-snap_dl-bt2").removeAttr("disabled");
    $("#cnm-snap_del-bt2").removeAttr("disabled");
  }
}

function show_csm_snap_Date1(data,id){
  var txt = data;
  $("#csm-snap_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#csm-snap_dl-bt1").attr("disabled",true);
    $("#csm-snap_del-bt1").attr("disabled",true);
  } else {
    $("#csm-snap_dl-bt1").removeAttr("disabled");
    $("#csm-snap_del-bt1").removeAttr("disabled");
  }
}

function show_VSYS_DB_Date1(data,id){
  var txt = data;
  $("#vsys-db_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#vsys-db_dl-bt1").attr("disabled",true);
    $("#vsys-db_del-bt1").attr("disabled",true);
  } else {
    $("#vsys-db_dl-bt1").removeAttr("disabled");
    $("#vsys-db_del-bt1").removeAttr("disabled");
  }
}

function show_VSYS_DB_Date2(data,id){
  var txt = data;
  $("#vsys-db_date2").text(txt);
  if (txt.match(/N\/A/)) {
    $("#vsys-db_dl-bt2").attr("disabled",true);
    $("#vsys-db_del-bt2").attr("disabled",true);
  } else {
    $("#vsys-db_dl-bt2").removeAttr("disabled");
    $("#vsys-db_del-bt2").removeAttr("disabled");
  }
}

function show_VSYS_AP_Date1(data,id){
  var txt = data;
  $("#vsys-ap_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#vsys-ap_dl-bt1").attr("disabled",true);
    $("#vsys-ap_del-bt1").attr("disabled",true);
  } else {
    $("#vsys-ap_dl-bt1").removeAttr("disabled");
    $("#vsys-ap_del-bt1").removeAttr("disabled");
  }
}

function show_VSYS_AP_Date2(data,id){
  var txt = data;
  $("#vsys-ap_date2").text(txt);
  if (txt.match(/N\/A/)) {
    $("#vsys-ap_dl-bt2").attr("disabled",true);
    $("#vsys-ap_del-bt2").attr("disabled",true);
  } else {
    $("#vsys-ap_dl-bt2").removeAttr("disabled");
    $("#vsys-ap_del-bt2").removeAttr("disabled");
  }
}

function show_CHARGE_Date1(data,id){
  var txt = data;
  $("#charge_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#charge_dl-bt1").attr("disabled",true);
    $("#charge_del-bt1").attr("disabled",true);
  } else {
    $("#charge_dl-bt1").removeAttr("disabled");
    $("#charge_del-bt1").removeAttr("disabled");
  }
}

function show_SWCM_Date1(data,id){
  var txt = data;
  $("#swcm_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#swcm_dl-bt1").attr("disabled",true);
    $("#swcm_del-bt1").attr("disabled",true);
  } else {
    $("#swcm_dl-bt1").removeAttr("disabled");
    $("#swcm_del-bt1").removeAttr("disabled");
  }
}

function show_SWCM_Date2(data,id){
  var txt = data;
  $("#swcm_date2").text(txt);
  if (txt.match(/N\/A/)) {
    $("#swcm_dl-bt2").attr("disabled",true);
    $("#swcm_del-bt2").attr("disabled",true);
  } else {
    $("#swcm_dl-bt2").removeAttr("disabled");
    $("#swcm_del-bt2").removeAttr("disabled");
  }
}

function show_SWCM_Date3(data,id){
  var txt = data;
  $("#swcm_date3").text(txt);
  if (txt.match(/N\/A/)) {
    $("#swcm_dl-bt3").attr("disabled",true);
    $("#swcm_del-bt3").attr("disabled",true);
  } else {
    $("#swcm_dl-bt3").removeAttr("disabled");
    $("#swcm_del-bt3").removeAttr("disabled");
  }
}

function show_XEN_Date1(data,id){
  var txt = data;
  $("#xen_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#xen_dl-bt1").attr("disabled",true);
    $("#xen_del-bt1").attr("disabled",true);
  } else {
    $("#xen_dl-bt1").removeAttr("disabled");
    $("#xen_del-bt1").removeAttr("disabled");
  }
}

function show_csm_agent_snap_Date1(data,id){
  var txt = data;
  $("#csm-agent-snap_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#csm_agent_snap_dl-bt1").attr("disabled",true);
    $("#csm_agent_snap_del-bt1").attr("disabled",true);
  } else {
    $("#csm_agent_snap_dl-bt1").removeAttr("disabled");
    $("#csm_agent_snap_del-bt1").removeAttr("disabled");
  }
}

function show_KVM_Date1(data,id){
	var txt = data;
	$("#kvm_date1").text(txt);
	if (txt.match(/N\/A/)) {
		$("#kvm_dl-bt1").attr("disabled",true);
		$("#kvm_del-bt1").attr("disabled",true);
	} else {
		$("#kvm_dl-bt1").removeAttr("disabled");
		$("#kvm_del-bt1").removeAttr("disabled");
	}
}

function show_PCL_Date1(data,id){
  var txt = data;
  $("#pcl_date1").text(txt);
  if (txt.match(/N\/A/)) {
    $("#pcl_dl-bt1").attr("disabled",true);
    $("#pcl_del-bt1").attr("disabled",true);
  } else {
    $("#pcl_dl-bt1").removeAttr("disabled");
    $("#pcl_del-bt1").removeAttr("disabled");
  }
}

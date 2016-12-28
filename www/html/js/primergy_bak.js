function displayList(list,id){
	var num = 1;
	var txt="<table><tr>";
	var _selectWindow = document.getElementById(id);
	for(var l in list){
		for(var i in list[l]){
			if(list[l][i][1] != "OK"){
				txt += "<td><table border=1><tr><td width='100px' height='100px'><img title='"+list[l][i][0]+"' name='"+i+"' src='PrimNG.jpg' width='100%' hight='100%' onClick='get_status(this);'></td></tr><tr><td height='50px'>"+i+"</td></tr></table></td>";
			}else{
				txt += "<td><table border=1><tr><td width='100px' height='100px'><img title='"+list[l][i][0]+"' name='"+i+"' src='PrimOK.jpg' width='100%' hight='100%' onClick='get_status(this);'></td></tr><tr><td height='50px'>"+i+"</td></tr></table></td>";
			}
			var amari = num%8;
			if(!amari){
				txt += "</tr><tr>";
			}
			num++;
		}
	}

	txt += "</tr></table>";
	_selectWindow.innerHTML = txt;
}

function get_status(d){
	$("#main_window").html("");
	$("#events").html("");
	var value = $(d).attr('name');
	var url = "/cgi-bin/resource/getPrimergyStatus.cgi?primergy="+value;
	var divEle = document.getElementById("main_window");
	sendReceiveJSON("GET",url,null,enclosureHTML,"main_window");
}

function enclosureHTML(data,id){
}

function displayList_SVRM(list,id){
	var num = 1;
	var txt="<table><tr>";
	var _selectWindow = document.getElementById(id);
	for(var l in list){
		for(var i in list[l]){
			for(var j in list[l][i]){
				if((list[l][i][j][0] == "Operational") && (list[l][i][j][1] == "Operational")){
					txt += "<td><table border=1><tr><td id='"+i+"' width='100px' height='100px'><img title='"+j+"' name='"+i+"' src='PrimOK.jpg' width='100%' hight='100%' onClick='get_status_SVRM(this);'></td></tr><tr><td height='50px'>"+i+"</td></tr></table></td>";
				}else{
					txt += "<td><table border=1><tr><td id='"+i+"' width='100px' height='100px'><img title='"+j+"' name='"+i+"' src='PrimNG.jpg' width='100%' hight='100%' onClick='get_status_SVRM(this);'></td></tr><tr><td bgcolor='#FF33FF' height='50px'>"+i+"</td></tr></table></td>";
				}
			}
			var amari = num%8;
			if(!amari){
				txt += "</tr><tr>";
			}
			num++;
		}
		l += 2;
	}
	txt += "</tr></table>";
	_selectWindow.innerHTML = txt;
}

function get_status_SVRM(d){
	$("#main_window").html("");
//	$("#events").html("");
	var value = $(d).attr('name');
	var host = sessionStorage.getItem("selected_host");
	if(host != ""){
		$("#"+host).attr("bgcolor","");
	}
	sessionStorage.setItem("selected_host",value);
	$("#"+value).attr("bgcolor","yellow");
	var url = "/cgi-bin/resource/serverview_cmd.cgi?dom0="+value;
	var divEle = document.getElementById("main_window");
	sendReceiveJSON("GET",url,null,enclosureHTML_SVRM,"main_window");
}

function enclosureHTML_SVRM(list,id){
	var txt = "<table border=1><tr><th>Disk#1</th><th>Disk#2</th><th>RAID Card</th></tr><tr>";
	var _SVRM_window = document.getElementById(id);
	for(var l in list.raid){
		txt += "<td valign='top'><table><tr><td><table id='table"+l+"' border=2>";
		for(var i in list.raid[l]){
			txt += "<tr><td>("+i+")</td><td>"+list.raid[l][i][0]+"</td><td>"+list.raid[l][i][1]+"</td></tr>"; 
		}
	txt += "</table></td></tr></table></td>";
	}
	txt += "</tr></table>";
	txt += "<table border=1>";
	txt += "<br><br>";
	txt += "<tr><td>No</td><td>Running DomUs</td></tr>";
	var vmflag = 0;
	for(var i in list.domu){
		vmflag++;
		if(isEven(i)){
			txt += "<tr><td>"+i+"</td><td>"+list.domu[i]+"</td></tr>";
		}else{
			txt += "<tr bgcolor='#FAEBD7'><td>"+i+"</td><td>"+list.domu[i]+"</td></tr>";
		}
	}
	txt += "</table>";
	var _div = document.getElementById("islandList");
	var island = _div.options[_div.selectedIndex].value;
	if(vmflag != 0 && island != "region"){
		txt += "<button Onclick='migration();'>migration</button>";
	}

	_SVRM_window.innerHTML = txt;

	for(var l in list){
		for(var i in list[l]){
			if(list[l][i][0]=="Status" && list[l][i][1]!="Operational"){
				$("#table"+l).attr("bgcolor","red");
			}
		}
	}
}

function migration(){
	$("#migration_window").html("");
	var dom0 = sessionStorage.getItem("selected_host");
	var _div = document.getElementById("islandList");
	var island = _div.options[_div.selectedIndex].value+"-cbrm";
	var url = "/cgi-bin/resource/migration_cmd.cgi?dom0="+dom0+"&island="+island;
	var divEle = document.getElementById("migration_window");
	sendReceiveTXT("GET",url,null,migration2,"migration_window");
}

function migration2(data,id){
  alert (data);
  var _M_window = document.getElementById(id);
  _M_window.innerHTML = txt;
}


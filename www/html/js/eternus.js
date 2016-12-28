function displayList(list,id){
	var num = 1;
	var txt="<table><tr>";
	var _selectWindow = document.getElementById(id);
	for(var l in list){
		for(var i in list[l]){
			if(list[l][i][1] != "Normal"){
				txt += "<td><table border=1><tr><td width='100px' height='100px'><img title='"+list[l][i][0]+"' name='"+list[l][i][0]+"' src='Error.jpg' width='100%' hight='100%' onClick='get_status(this);'></td></tr><tr><td height='50px'>"+i+"</td></tr></table></td>";
			}else{
				txt += "<td><table border=1><tr><td width='100px' height='100px'><img title='"+list[l][i][0]+"' name='"+list[l][i][0]+"' src='Normal.jpg' width='100%' hight='100%' onClick='get_status(this);'></td></tr><tr><td height='50px'>"+i+"</td></tr></table></td>";
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
	var url = "/cgi-bin/resource/getEternusStatus.cgi?eternus="+value;
	//json = $.parseJSON(sendReceiveJSON("GET",url,null));
	var divEle = document.getElementById("main_window");
	sendReceiveJSON("GET",url,null,enclosureHTML,"main_window")
	//divEle.innerHTML = enclosureHTML(json);
	url = "/cgi-bin/resource/getEternusEvents.cgi?eternus="+value;
	sendReceiveTXT("GET",url,null,eventsTXT,"events");
	//var events = document.getElementById("events");
}

function enclosureHTML(data,id){
	var txt = "";
	txt += '<table border=1>';
	txt += '	<tr>';
	txt += '		<td>HOSTNAME</td><td><p>'+data['hostname']+'</p></td>';
	txt += '		<td rowspan=4 colspan=12>' + advise(data) + '</td>';
	txt += '	</tr>';
	txt += '	<tr>';
	txt += '		<td>SERIAL Number</td><td><p>'+data['serial']+'</p></td>';
	txt += '	</tr>';
	txt += '	<tr>';
	txt += '		<td>Firmware Version</td><td><p>'+data['firmware']+'</p></td>';
	txt += '	</tr>';
	txt += '	<tr>';

// Main Status
	txt += '	<td>Status</td><td>';
	if(data.status == "Normal"){
		txt += '<p>'+data.status+'</p>';
	}else if(data.status == "Warning"){
		txt += '<p><font color="yellow">'+data.status+'</font></p>';
	}else if(data.status == "Error"){
		txt += '<p><font color="red">'+data.status+'</font></p>';
	}
	txt += '	</td>';
	txt += '</tr><tr>';

// CE Status
	txt += '	<td>Control Enclosure</td><td>';
	if(data.ce_status == "Normal"){
		txt += '<p>'+data.ce_status+'</p>';
	}else if(data.ce_status == "Warning"){
		txt += '<p><font color="yellow">'+data.ce_status+'</font></p>';
	}else if(data.ce_status == "Error"){
		txt += '<p><font color="red">'+data.ce_status+'</font></p>';
	}
	txt += '	</td>';
	txt += DiskStatus(data,'CE');
	txt += '</tr><tr>';

// DE #1 Status
	txt += '	<td>Drive Enclosure #1</td><td>';
	if(data.de1_status == "Normal"){
		txt += '<p>'+data.de1_status+'</p>';
	}else if(data.de1_status == "Warning"){
		txt += '<p><font color="yellow">'+data.de1_status+'</font></p>';
	}else if(data.de1_status == "Error"){
		txt += '<p><font color="red">'+data.de1_status+'</font></p>';
	}
	txt += '	</td>';
	txt += DiskStatus(data,'DE #1');
	txt += '</tr><tr>';

// DE #2 Status
	txt += '	<td>Drive Enclosure #2</td><td>';
	if(data.de2_status == "Normal"){
		txt += '<p>'+data.de2_status+'</p>';
	}else if(data.de2_status == "Warning"){
		txt += '<p><font color="yellow">'+data.de2_status+'</font></p>';
	}else if(data.de2_status == "Error"){
		txt += '<p><font color="red">'+data.de2_status+'</font></p>';
	}
	txt += '	</td>';
	txt += DiskStatus(data,'DE #2');
	txt += '</tr></table>'
	help();
	var divEle = document.getElementById(id);
	divEle.innerHTML = txt;

//return txt;
}

function DiskStatus(json,type){
var color;

	var sub = "";
	for(var i in json[type]){
		if(json[type][i] == "Available"){
			color = "white";
		}else if(json[type][i] == "Broken"){
			color = "red";
		}else if(json[type][i] == "Spare"){
			color = "blue";
		}else{
			color = "grey";
		}
		sub += '<td bgcolor="'+color+'">Disk #'+i+'</td>';
	}

return sub;
}

function help(){
	var help = document.getElementById("help_window");
	var txt = "";
	txt += '<table border=1>';
	txt += '	<tr>';
	txt += '		<td bgcolor="white" width="50px" rowspan="4"><font color="blue" size="15px">Status</font></td>';
	txt += '		<td bgcolor="white" width="10px"></td><td>Available</td>';
	txt += '	</tr>';
	txt += '	<tr>';
	txt += '		<td bgcolor="red" width="10px"></td><td>Broken</td>';
	txt += '	</tr>';
	txt += '	<tr>';
	txt += '		<td bgcolor="grey" width="10px"></td><td>Not Available</td>';
	txt += '	</tr>';
	txt += '	<tr>';
	txt += '		<td bgcolor="blue" width="10px"></td><td>Spare</td>';
	txt += '	</tr>';
	txt += '</table>';

	help.innerHTML = txt;

return 0;
}

function advise(data){
	//var sub_window = document.getElementById("sub_window");
//	txt += '<table>';
//	txt += '	<tr>';
//	txt += '		<td>';
//	var txt = 'There are no Broken Disks. <br>You can sit back, relax and have a coffee.';
var txt = "";
//	txt += '		</td>';
//	txt += '	</tr>';
//	txt += '</table>';

	//sub_window.innerHTML = txt;

return txt;
}

function eventsTXT(txt,id){
	$("#"+id).html('<p><font size="15px" color="blue">Events</font></p><pre>'+txt+'</pre>');
	//events = document.getElementById(id);
	//events.innerHTML = '<p><font size="15px" color="blue">Events</font></p><pre>'+txt+'</pre>';
}

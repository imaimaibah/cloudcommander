function createTabs(data,id){
	setsessionStorage(data.transfer,"transfer");
	setsessionStorage(data.currency,"currency");
	setsessionStorage(data.hostlead,"hostlead");
	createTransferTable();
	createHostLeadTable();
	createCurrencyTable();
	leadinvoice();
	contractinvoice();
}

function createTransferTable(){
	var txt = "";
	var data = JSON.parse(sessionStorage.getItem("transfer"));
	var currency = JSON.parse(sessionStorage.getItem("currency"));
	var option = $("#code option:selected").val();
	if(option == undefined){
		option = 'all';
	}
	var re = new RegExp("^" + option);

	txt += "<button id='commit' onClick='CommitChange();'>Commit</button>";
	txt += "<button id='refresh' onClick='createTransferTable();'>Refresh</button>";

	txt += "<table id='transtable' border=1><tr bgcolor='grey'>";
	for(var i in data[0]){
		txt += "<td>"+data[0][i]+"</td>";
	}
	txt += "</tr><tr>";
	for (var i = 1; i < data.length; i++){
		if(!data[i][0].match(re) && option != 'all'){
			continue;
		}
		for(var l in data[i]){
			if(l<3){
				txt += "<td>"+data[i][l]+"</td>";
			}else{
				txt += "<td><input type='text' value='"+data[i][l]+"' /></td>";
			}
		}
		txt += "</tr><tr>";
	}
	txt += "</tr></table>";
	$("#transfer_price").html(txt);
}

function createHostLeadTable(){
	var data = JSON.parse(sessionStorage.getItem("hostlead"));
	var txt = "";
	txt += "<table id='hostleadtable' border=1><tr>";
	for(var i in data[0]){
		txt += "<td bgcolor='grey'>"+data[0][i]+"</td>";
	}
	txt += "</tr><tr>";
	for(var i=1;i<data.length;i++){
		for(var l in data[i]){
			txt += "<td>"+data[i][l]+"</td>"
		}
		txt += "</tr><tr>";
	}
	txt += "</tr></table>";
	$("#host_lead").html(txt);

}

function createCurrencyTable(){
	var data = JSON.parse(sessionStorage.getItem("currency"));
	var txt = "";
	txt += "<table id='currencytable' border=1><tr>";
	for(var i in data[0]){
		txt += "<td bgcolor='grey'>"+data[0][i]+"</td>";
	}
	txt += "</tr><tr>";
	for(var i=1;i<data.length;i++){
		for(var l in data[i]){
			txt += "<td>"+data[i][l]+"</td>"
		}
		txt += "</tr><tr>";
	}
	txt += "</tr></table>";
	$("#currency").html(txt);
}

function CommitChange(){
	var old_data = JSON.parse(sessionStorage.getItem("transfer"));
	var new_data = new Array;
	var table = document.getElementById('transtable');
	var tr = table.getElementsByTagName('tr')
	for(var i = 0;i<tr.length;i++){
		var td = tr[i].getElementsByTagName('td');
		new_data[i] = new Array;
		for(var l=0;l<td.length;l++){
			if(td[l].childNodes[0].nodeValue == null){
				new_data[i][l] = td[l].childNodes[0].value;
			}else{
				new_data[i][l] = td[l].childNodes[0].nodeValue;
			}
		}
	}

	var txt = "";
	var change = 0;
	txt += "<tr>";
	for(var i in old_data[0]){
		txt += "<td>"+old_data[0][i]+"</td>";
	}
	txt += "</tr><tr>";
	txt += "</tr>";
	for(var i=1;i<old_data.length;i++){
		for(var l=0;l<old_data[i].length;l++){
			if(l>2 && new_data[i][l] != old_data[i][l]){
				txt += "<td bgcolor='yellow'>"+old_data[i][l]+" => "+new_data[i][l]+"</td>";
				change++;
				old_data[i][l] = new_data[i][l];
			}else{
				txt += "<td>"+old_data[i][l]+"</td>";
			}
		}
		txt += "</tr><tr>";
	}
	txt += "</tr>";
	if(change){
		$("#transtable").html("");
		$("#transtable").html(txt);
		$("#commit").html("Confirm");
		$("#commit").removeAttr("onClick");
		$("#refresh").html("Back");
		$("#refresh").removeAttr("onClick");
		$("#commit").click(function(){
			sessionStorage.setItem("transfer",JSON.stringify(old_data));
			$("#commit").html("Commit");
			createTransferTable();
		});
		$("#refresh").click(createTransferTable);
	}

return 0;
}


function contractinvoice(){
		var txt = "";
		txt += "<table>";
		txt += "	<tr>";
		txt += "		<td>Contract ID: ";
		txt += "			<input id='cnt' type='txt' />";
		txt += "			<button onClick='getinvoice();'>Get</button>";
		txt += "			<button onClick='getinvoice();'>Download</button>";
		txt += "		</td>";
		txt += "	</tr>";
		txt += "		<td><div id='invoicetable'></div></td>";
		txt += "	</tr>";
		txt += "</table>";
		$("#invoice").html(txt);
}

function getinvoice(){
	var re = new RegExp("^[0-9A-Z]{8}$");
	var cnt = $("#cnt").val();
	if(!cnt.match(re)){
		alert("Wrong CNT ID");
		return;
	}
	var url = '/cgi-bin/billing_system/getCNTInvoice.cgi?cnt='+cnt;
	sendReceiveTXT("GET",url,null,createInvoiceTable,"invoicetable");
}

function createInvoiceTable(data,id){
	var j = data.split("\n")
	var txt = "<table border=1>";
	txt += "<tr bgcolor='grey'><td>Product Name</td><td>List Price</td><td>Transfer Price</td><td>Unit</td><td>Transfer Price Total</td><td>List Price Total</td></tr>";
	for(var l in j){
		txt += "<tr>"
		var l = j[l].split(",");
		for(var m in l){
			txt += "<td>"+l[m]+"</td>";
		}
			txt += "</tr>";
	}
	txt += "</table>";
	$("#"+id).html(txt);
}


function leadinvoice(){
	var data = JSON.parse(sessionStorage.getItem("hostlead"));
	var txt = "";
	txt += "<select onChange=''>";
	txt += "<option selected>all</option>"
	var tmp = new Array;
	for(var i=1;i<data.length;i++){
		tmp[data[i][2]] = 1;
	}
	for(var i in tmp){
		txt += "<option>"+i+"</option>";
	}
	txt += "</select>";
	txt += "<button onClick=''>download</button>";
	$("#leadinvoice").html(txt);
	
}

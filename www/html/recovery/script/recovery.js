var vsysResourceList;
var rorResourceList;

function vsysList(obj){
	var str = '';

//	try{
		vsysResourceList = new Array();

		var systemId = XPathContent(obj,"//Vsys/vsysId","-");
		var resourceId = XPathContent(obj,"//Vsys/resourceId","-");
		var systemName = XPathContent(obj,"//Vsys/systemName","-");
		var systemStatus = XPathContent(obj,"//Vsys/status",null);
		if(systemStatus == null){
			return "";
		}

		// VSYSèÓïÒ
		vsysResourceList[systemId] = new Array();
		vsysResourceList[systemId]["category"] = "system";
		vsysResourceList[systemId]["connect"] = false;
		vsysResourceList[systemId]["label"] = systemName;
		vsysResourceList[systemId]["id"] = resourceId;
		str += '<div class="radius vsys">';
		str += '<table id="' + systemId + '_VSYS" border=0 cellspacing=0 cellpadding=0 width=100%>';
		str += '	<tr>';
		str += '		<td valign=top width=40px nowrap><img width=32px src="img/system.png"><td>';
		str += '		<td width=100%>';
		str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
		str += '				<tr>';
		str += '					<td colspan=2><div class="name_line">' + systemName + '</div></td>';
		str += '				</tr>';
		str += '				<tr>';
		str += '					<td>System ID</td>';
		str += '					<td>' + systemId + '</td>';
		str += '				</tr>';
		str += '				<tr>';
		str += '					<td>Resource ID</td>';
		str += '					<td>' + resourceId + '</td>';
		str += '				</tr>';
		str += '			</table>';
		str += '		</td>';
		str += '	</tr>';
		str += '</table>';
		str += '</div>';

		//ServerèÓïÒ
		var servers = XPathList(obj,"//Vsys/servers/server","-");
		for(var idx=0;idx<servers.snapshotLength;idx++){
			var serverId = XPathContent(servers.snapshotItem(idx),"serverId","");
			var diskId = XPathContent(servers.snapshotItem(idx),"diskId","")
			var serverLabel = XPathContent(servers.snapshotItem(idx),"serverName","");
			var resourceId = XPathContent(servers.snapshotItem(idx),"resourceId","");
			var status = XPathContent(servers.snapshotItem(idx),"status","");
			var diskResourceId = XPathContent(servers.snapshotItem(idx),"diskResourceId","");
			vsysResourceList[serverId] = new Array();
			vsysResourceList[serverId]["category"] = "server";
			vsysResourceList[serverId]["connect"] = false;
			vsysResourceList[diskId] = new Array();
			vsysResourceList[diskId]["category"] = "sysvol";
			vsysResourceList[diskId]["connect"] = false;
			vsysResourceList[serverId]["label"] = serverLabel;
			vsysResourceList[serverId]["id"] = resourceId;
			vsysResourceList[serverId]["status"] = status;
			vsysResourceList[diskId]["id"] = diskResourceId
			str += '<div class="radius server">';
			str += '<table id="' + serverId + '_VSYS" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '	<tr>';
			str += '		<td valign=top width=40px nowrap><img src="img/computer.png"><td>';
			str += '		<td>';
			str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
			str += '				<tr>';
			str += '					<td colspan=2><div class="name_line">' + serverLabel + '</div></td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Server ID</td>';
			str += '					<td>' + serverId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Resource ID</td>';
			str += '					<td>' + resourceId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Status</td>';
			str += '					<td>' + status + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td colspan=2>';
			str += '						<div class="radius disk">';
			str += '							<table id="' + diskId + '_VSYS" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '								<tr>';
			str += '									<td valign=top width=40px nowrap><img src="img/hd.png"><td>';
			str += '									<td>';
			str += '										<table class="content" width=100% cellspacing=0 cellpadding=0>';
			str += '											<tr>';
			str += '												<td colspan=2><div class="name_line">SYSVOL</div></td>';
			str += '											</tr>';
			str += '											<tr>';
			str += '												<td>Disk ID</td>';
			str += '												<td>' + diskId + '</td>';
			str += '											</tr>';
			str += '											<tr>';
			str += '												<td>Resource ID</td>';
			str += '												<td>' + diskResourceId + '</td>';
			str += '											</tr>';
			str += '										</table>';
			str += '									</td>';
			str += '								</tr>';
			str += '							</table>';
			str += '						</div>';
			str += '					</td>';
			str += '				</tr>';
			str += '			</table>';
			str += '		</td>';
			str += '	</tr>';
			str += '</table>';
			str += '</div>';
		}
		//DiskèÓïÒ
		var disks = XPathList(obj,"//Vsys/disks/disk","-");
		for(var idx=0;idx<disks.snapshotLength;idx++){
			var diskId = XPathContent(disks.snapshotItem(idx),"diskId","");
			var diskLabel = XPathContent(disks.snapshotItem(idx),"diskName","");
			var resourceId = XPathContent(disks.snapshotItem(idx),"resourceId","");
			var diskIndex = XPathContent(disks.snapshotItem(idx),"diskIndex","");
			var diskCategory = XPathContent(disks.snapshotItem(idx),"diskCategory","");
			var serverId = XPathContent(disks.snapshotItem(idx),"serverId","");
			var status = XPathContent(disks.snapshotItem(idx),"status","");
			vsysResourceList[diskId] = new Array();
			vsysResourceList[diskId]["category"] = "disk";
			vsysResourceList[diskId]["connect"] = false;
			vsysResourceList[diskId]["label"] = diskLabel;
			vsysResourceList[diskId]["id"] = resourceId;
			vsysResourceList[diskId]["index"] = diskIndex;
			vsysResourceList[diskId]["diskCategory"] = diskCategory;
			vsysResourceList[diskId]["serverId"] = serverId;
			vsysResourceList[diskId]["status"] = status;
			str += '<div class="radius disk">';
			str += '<table id="' + diskId + '_VSYS" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '	<tr>';
			str += '		<td valign=top width=40px nowrap><img src="img/disk.png"><td>';
			str += '		<td>';
			str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
			str += '				<tr>';
			if(diskCategory == "BACKUP"){
				str += '					<td colspan=2><div class="name_line">BACKUP</div></td>';
			}else{
				str += '					<td colspan=2><div class="name_line">' + diskLabel + '</div></td>';
			}
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Disk ID</td>';
			str += '					<td>' + diskId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Resource ID</td>';
			str += '					<td>' + resourceId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Disk Index</td>';
			str += '					<td>' + diskIndex + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Category</td>';
			str += '					<td>' + diskCategory + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Server ID</td>';
			str += '					<td>' + serverId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Status</td>';
			str += '					<td>' + status + '</td>';
			str += '				</tr>';
			str += '			</table>';
			str += '		</td>';
			str += '	</tr>';
			str += '</table>';
			str += '</div>';
		}
/*
	}catch(e){
		alert(e + "\n in VsysList");
	}
*/
	return str;
}

function rorList(obj){
	var str = '';

//	try{
		rorResourceList = new Array();

		var folder = XPathElem(obj,"//ror/Folder","-");
		var systemId = folder.getAttribute("name");
		var resourceId = folder.getAttribute("id");
		var systemName = XPathContent(obj,"//ror/Folder/Comment","-");

		// VSYSèÓïÒ
		rorResourceList[systemId] = new Array();
		rorResourceList[systemId]["category"] = "system";
		rorResourceList[systemId]["connect"] = false;
		rorResourceList[systemId]["label"] = systemName;
		rorResourceList[systemId]["id"] = resourceId;
		str += '<div class="radius vsys">';
		str += '<table id="' + systemId + '_ROR" border=0 cellspacing=0 cellpadding=0 width=100%>';
		str += '	<tr>';
		str += '		<td valign=top width=40px nowrap><img width=32px src="img/system.png"><td>';
		str += '		<td width=100%>';
		str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
		str += '				<tr>';
		str += '					<td colspan=2><div class="name_line">' + systemName + '</div></td>';
		str += '				</tr>';
		str += '				<tr>';
		str += '					<td>SystemID</td>';
		str += '					<td>' + systemId + '</td>';
		str += '				</tr>';
		str += '				<tr>';
		str += '					<td>Resource ID</td>';
		str += '					<td>' + resourceId + '</td>';
		str += '				</tr>';
		str += '			</table>';
		str += '		</td>';
		str += '	</tr>';
		str += '</table>';
		str += '</div>';

		//ServerèÓïÒ
		var diskLinkMap = new Array();
		var diskIndexMap = new Array();
		var servers = XPathList(obj,"//ror/Folder/LServer","-");
		for(var idx=0;idx<servers.snapshotLength;idx++){
			var serverElem = servers.snapshotItem(idx);
			var serverId = serverElem.getAttribute("name");
			var resourceId = serverElem.getAttribute("id");
			var serverName = XPathContent(serverElem,"Comment","");
			var diskList = XPathList(serverElem,"Disks/Disk");
			var diskId = "";
			var diskResourceId = "";
			var status = XPathContent(serverElem,"Status/PowerStatus","");
			for(var diskIdx=0;diskIdx<diskList.snapshotLength;diskIdx++){
				var diskElem = diskList.snapshotItem(diskIdx);
				var diskIndex = XPathContent(diskElem,"DiskIndex","-");
				if(diskIndex != null && diskIndex == "0"){
					var diskLinkElem = XPathElem(diskElem,"DiskLink",null);
					diskId = diskLinkElem.getAttribute("name");
					diskResourceId = diskLinkElem.getAttribute("id");
				}else{
					var diskLinkElem = XPathElem(diskElem,"DiskLink",null);
					diskLinkMap[diskLinkElem.getAttribute("name")] = serverId;
					diskIndexMap[diskLinkElem.getAttribute("name")] = diskIndex;
				}
			}
			rorResourceList[serverId] = new Array();
			rorResourceList[serverId]["connect"] = false;
			rorResourceList[serverId]["category"] = "server";
			rorResourceList[serverId]["id"] = resourceId;
			rorResourceList[serverId]["label"] = serverName;
			rorResourceList[serverId]["status"] = status
			rorResourceList[diskId] = new Array();
			rorResourceList[diskId]["connect"] = false;
			rorResourceList[diskId]["category"] = "sysvol";
			rorResourceList[diskId]["id"] = diskResourceId;
			str += '<div class="radius server">';
			str += '<table id="' + serverId + '_ROR" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '	<tr>';
			str += '		<td valign=top width=40px nowrap><img src="img/computer.png"><td>';
			str += '		<td>';
			str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
			str += '				<tr>';
			str += '					<td colspan=2><div class="name_line">' + serverName + '</div></td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Server ID</td>';
			str += '					<td>' + serverId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Resource ID</td>';
			str += '					<td>' + resourceId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Status</td>';
			if(status == "on"){
				str += '					<td>' + status + '&nbsp;<input type=button value="power off (force)" onclick="javascript:forceStop(this,\'' + resourceId + '\')" style="height:16px;font-size:6pt;padding-top:0;"></td>';
			}else{
				str += '					<td>' + status + '</td>';
			}
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td colspan=2>';
			str += '						<div class="radius disk">';
			str += '							<table id="' + diskId + '_ROR" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '								<tr>';
			str += '									<td valign=top width=40px nowrap><img src="img/hd.png"><td>';
			str += '									<td>';
			str += '										<table class="content" width=100% cellspacing=0 cellpadding=0>';
			str += '											<tr>';
			str += '												<td colspan=2><div class="name_line">SYSVOL</div></td>';
			str += '											</tr>';
			str += '											<tr>';
			str += '												<td>Disk ID</td>';
			str += '												<td>' + diskId + '</td>';
			str += '											</tr>';
			str += '											<tr>';
			str += '												<td>Resource ID</td>';
			str += '												<td>' + diskResourceId + '</td>';
			str += '											</tr>';
			str += '										</table>';
			str += '									</td>';
			str += '								</tr>';
			str += '							</table>';
			str += '						</div>';
			str += '					</td>';
			str += '				</tr>';
			str += '			</table>';
			str += '		</td>';
			str += '	</tr>';
			str += '</table>';
			str += '</div>';
		}

		//DiskèÓïÒ
		var disks = XPathList(folder,"Disk");
		for(var idx=0;idx<disks.snapshotLength;idx++){
			var diskId = disks.snapshotItem(idx).getAttribute("name");
			if(rorResourceList[diskId] != null) continue;
			rorResourceList[diskId] = new Array();
			rorResourceList[diskId]["connect"] = false;
			rorResourceList[diskId]["category"] = "disk";
			rorResourceList[diskId]["label"] = diskName;
			rorResourceList[diskId]["id"] = resourceId;
			rorResourceList[diskId]["index"] = diskIndexMap[diskId];
			rorResourceList[diskId]["serverId"] = diskLinkMap[diskId];

			var resourceId = disks.snapshotItem(idx).getAttribute("id");
			var diskName = XPathContent(disks.snapshotItem(idx),"Comment","");
			var label = disks.snapshotItem(idx).getAttribute("label");
			str += '<div class="radius disk">';
			str += '<table id="' + diskId + '_ROR" border=0 cellspacing=0 cellpadding=0 width=100%>';
			str += '	<tr>';
			str += '		<td valign=top width=40px nowrap><img src="img/disk.png"><td>';
			str += '		<td>';
			str += '			<table class="content" width=100% border=0 cellspacing=0 cellpadding=0>';
			str += '				<tr>';
			if(label == "BACKUP"){
				str += '					<td colspan=2><div class="name_line">BACKUP</div></td>';
			}else{
				str += '					<td colspan=2><div class="name_line">' + diskName + '</div></td>';
			}
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Disk ID</td>';
			str += '					<td>' + diskId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Resource ID</td>';
			str += '					<td>' + resourceId + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Disk Index</td>';
			if(diskIndexMap[diskId] != null){
				str += '					<td>' + diskIndexMap[diskId] + '</td>';
			}else{
				str += '					<td>-</td>';
			}
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Category</td>';
			str += '					<td>' + label + '</td>';
			str += '				</tr>';
			str += '				<tr>';
			str += '					<td>Server ID</td>';
			if(diskLinkMap[diskId] != null){
				str += '					<td>' + diskLinkMap[diskId] + '</td>';
			}else{
				str += '					<td>-</td>';
			}
			str += '				</tr>';
			str += '			</table>';
			str += '		</td>';
			str += '	</tr>';
			str += '</table>';
			str += '</div>';
		}
/*
	}catch(e){
		alert(e + "\n in RorList");
	}
*/
	return str;
}

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

function XPathElem(obj,path,nullContent){
	var elem = document.evaluate(path,obj,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null);
	if(elem != null) return elem.singleNodeValue;
	return null;
}

function XPathList(obj,path,nullContent){
	var elem = document.evaluate(path,obj,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE ,null);
	if(elem != null) return elem;
	if(nullContent != null) return nullContent;
	return null;
}

#!/usr/bin/perl -I/usr/local/2nd_tools/lib

$|=1;

use env;
use func;
use audit;
my $base_dir = $env::base_dir;
my $region = $env::region;
my $region_num = $env::region_num;
my $audit = new audit();
my $obj = new multiRegion();
$obj->getRegion();
my @region;
foreach my $region(@{$obj->{'region'}}){
	push(@region,$region->[0]);
}
$obj = undef;


start_page();


#################################################
#
# PAGE FUNCTION
#
#################################################

sub start_page(){
while(1){
system("clear");
	logo::logo();
	print <<EOF;
1 - Eternus
2 - Primergy
3 - Dom0
4 - Password change for cockpit
5 - WShutdown/10mins issue
6 - Initialize SSL-VPN password
7 - Force Release(VSYS)
8 - Quota
9 - Search Resources
0 - Quit
EOF
print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if("x$choice" eq "x1"){
		eternus_page1();
	}elsif("x$choice" eq "x2"){
		primergy_page1();
	}elsif("x$choice" eq "x3"){
		dom0_page1();
	}elsif("x$choice" eq "x4"){
		ldap_pass();
	}elsif("x$choice" eq "x5"){
		wshutdown();
	}elsif("x$choice" eq "x6"){
		initialize();
	}elsif("x$choice" eq "x7"){
		forceRelease();
	}elsif("x$choice" eq "x8"){
		quota();
	}elsif("x$choice" eq "x9"){
		search();
	}elsif("x$choice" eq "x0"){
		exit;
	}
}

return 0;
}

sub eternus_page1(){
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - csmRedundancy
2 - status check
0 - Go back
EOF
	print "Choose the number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if("x$choice" eq "x1"){
		my $ret = showCMRedundancy();
		if($ret eq 1){
			next;
		}
	}elsif("x$choice" eq "x2"){
		my $ret = eternus_page2();
		if($ret eq 128){
			next;
		}
	}elsif("x$choice" eq "x0"){
		last;
	}else{
		next;
	}
	print "Hit Enter";
	<STDIN>;
}
return 0;
}

sub eternus_page2(){
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - status
2 - volume status
3 - Event logs
0 - Go back
EOF
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	my $obj = new chk_validity();
	if("x$choice" eq "x1"){
		print "Enter eternus name or IP\n\t>>";
		my $eternus = readline(STDIN);
		chomp($eternus);
		my $ret = $obj->chk_eternus($eternus,\@region);
		if($ret eq 0){
			print "Invalid value is specified\n";
		}else{
			open(IN,"expect -f $base_dir/exp/eternus_status_check.exp $eternus |");
			while(<IN>){ 
				print;
			}
			close(IN);
		}
	}elsif("x$choice" eq "x2"){
		print "Enter eternus name or IP\n\t>>";
		my $eternus = readline(STDIN);
		chomp($eternus);
		my $ret = $obj->chk_eternus($eternus,\@region);
		if($ret eq 0){
			print "Invalid value is specified\n";
		}else{
			open(IN,"expect -f $base_dir/exp/eternus_status_check.exp $eternus -v |");
			while(<IN>){ 
				print;
			}
			close(IN);
		}
	}elsif("x$choice" eq "x3"){
		print "Enter eternus name or IP\n\t>>";
		my $eternus = readline(STDIN);
		chomp($eternus);
		my $ret = $obj->chk_eternus($eternus,\@region);
		if($ret eq 0){
			print "Invalid value is specified\n";
		}else{
			open(IN,"expect -f $base_dir/exp/eternus_status_check.exp $eternus -l |");
			while(<IN>){ 
				print;
			}
			close(IN);
		}
	}elsif("x$choice" eq "x0"){
		return 128;
	}else{
		next;
	}
	print "Hit Enter";
	<STDIN>;
}
return 0;
}

sub dom0_page1(){
while(1){
system("clear");
	logo::logo();
	print <<EOF;
1 - Show Dom0s in Maintenance mode 
0 - Go back
EOF
	print "Choose the number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if("x$choice" eq "x1"){
		my $ret = showDom0Mainte();
		if($ret eq 1){
			next;
		}
	}elsif("x$choice" eq "x2"){
		#setDom0Mainte();
	}elsif("x$choice" eq "x3"){
		DomU_verbose();
	}elsif("x$choice" eq "x0"){
		last;
	}else{
		next;
	}
	print "Hit Enter";
	<STDIN>;
}
return 0;
}

sub primergy_page1(){
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - Hardware Status Check
0 - Go back
EOF
	print "Choose the number >>";
	my $choice = readline(STDIN);
	chomp($choice);
	if("$choice" eq "1"){
		my $ret = statusPrimergy();
		if($ret eq 128){
			next;
		}
	}else{
		last;	
	}
	print "Hit Enter";
	<STDIN>;
return 0;
}
}

#################################################
#
# SUB FUNCTION
#
#################################################

sub showCMRedundancy(){
	system("clear");
	logo::logo();
	my $i = 1;
	foreach my $region(@region){
		print "$i - $region\n";
		$i++;
	}
	print "0 - Go Back\n";
	print "Choose the number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice ne 0){
		$choice--;
		open(IN,"$base_dir/bin/send_shell.sh -f $base_dir/csmCKRedundancy/csmCKRedundancy -h $region[$choice] -p sv\@01011 -u root|") or die "FAILED!!";
		while(<IN>){
			print; 
		}
		close(IN);
	}else{
		return 1;
	}

return 0;
}

sub showDom0Mainte(){
while(1){
	system("clear");
	logo::logo();
	my $i = 1;
	foreach my $region(@region){
		print "$i - $region\n";
		$i++;
	}
	print "0 - Go Back\n";
	print "Choose the number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice !~ /[0-9]+/){
		print "Invalid input found.\n";
		next;
	}
	if($choice ne 0){
		$choice--;
		if($region[$choice] eq ""){
			print "Invalid input found.\n";
			next;
		}
		open(IN,"$base_dir/exp/showDom0_mainte.exp $region[$choice]|");
		while(<IN>){
			my @youso = $_ =~ /[^\t\s]+/g;
			if($youso[4] =~ /ON/){
				print $youso[1]."\n";
			}
		}
		close(IN);
	}else{
		return 1;
	}
}
return 0;
}

sub setDom0Mainte(){
	print "Enter Dom0 you want to set in maintenance mode\n";
	print "\t>>";
	my $line = readline(<STDIN>);
	chomp($line);
	if($line =~ /(au|sg|us|gb|de)-01-1-ps000[01]-0[12345678]-[0-9]{2}/){
		system("expect -f /usr/local/2nd_tools/exp/setDom0Mainte.exp $line >/dev/null 2>&1");
	}else{
		print "wrong syntax\n";
		return 1;
	}
return 0;
}

sub password_change(){
	system("clear");
	logo::logo();
	my $obj = new password();
	my $ret = $obj->Pass_change();

return $ret;
}


sub wshutdown(){
	system("clear");
	logo::logo();
	print "Please Enter the VM ID\n";
	print ">> ";
	my $vm = <STDIN>;
	chomp($vm);
	my $obj = new validity;
	if(!$obj->vm($vm)){
		print "Invalid ID\n";
	}else{
		open(IN,"$base_dir/exp/wshutdown.exp $vm |");
		while(<IN>){
			print;
		}
		close(IN);
	}
	print "Hit Enter";
	<STDIN>;

return 0
}

sub statusPrimergy(){
	while(1){
		system("clear");
		logo::logo();
		print <<EOF;
1 - status
0 - Go back
EOF
		print "Chooose the number >> ";
		my $choice = readline(STDIN);
		chomp($choice);
		my $obj = new chk_validity();
		if("$choice" eq "1"){
			print "Enter primergy name or IP\n\t>> ";
			my $primergy = readline(STDIN);
			chomp($primergy);
			my $ret = $obj->chk_iRMC($primergy,\@region);
			if($ret eq 0){
				print "Invalid value is specified\n";
			}else{
				open(IN,"$base_dir/exp/pserver_irmc_check.exp $ret |");
				while(<IN>){
					print;
				}
				close(IN);
			}
		}elsif("$choice" eq "0"){
			return 128;
		}else{
			next;
		}
		print "Hit Enter";
		<STDIN>;
	}

return 0;
}

sub ldap_pass(){
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - Initialize
2 - Password Change(Your own)
0 - Go back
EOF
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice eq 1){
		ldapInitialize();
	}elsif($choice eq 2){
		password_change();
	}elsif($choice eq 0){
		last;
	}else{
		next;
	}
	print "Hit Enter";
	<STDIN>;
}

return 0;
}

sub ldapInitialize(){
	my @letters = ('a'..'z', 'A'..'Z', 0..9);
	my $length  = 16;
	my $loop    = 1;
	my $pass = "";

	for(1 .. $loop){
  		$pass .= $letters[int(rand(@letters))] for(1 .. $length);
	}
	system("clear");
	logo::logo();
	print "Enter userID or email address\n";
	print ">> ";
	my $uid = readline(STDIN);
	chomp($uid);
	$uid =~ s/@.*//;
	system("$base_dir/exp/ldapinitialize.exp $uid $pass");
	my $ret = $?>>8;
	if($ret eq 0){
		print "Success!!\n";
		$audit->audit("ldap password for $uid has been initialized.");
		my $obj = new password;
		$obj->update($pass);
	}else{
		print "Cannot find the user\n";
	}

return $ret;
}

sub initialize(){
	system("clear");
	logo::logo();
	print "Enter the user name\n";
	print ">> ";
	my $user = readline(STDIN);
	chomp($user);
	system("$base_dir/bin/ssl_vpn.pl $user");
	my $ret = $?;
	$ret>>8;
	if($ret eq 0){
		print "Success!!\n";
		$audit->audit("SSL-VPN password $user has been initialized.");
	} else {
		print "Failed\n";
		print "Please contact 2nd line support.\n"
	}
	print "Hit Enter";
	<STDIN>;

return 0;
}

sub forceRelease(){
	system("clear");
	logo::logo();
	my $obj = new sdm();
	$obj->forceRelease();

print <<EOF;
Hit Enter
EOF
	<STDIN>;

return 0;
}

sub quota(){
use quota;
	my $obj = new quota();
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - Get Template Info
2 - Get Users Info
3 - Assign Template
4 - Deassign Template
5 - Create Template
0 - Go back
EOF
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice eq 1){
		quota_1($obj);
	}elsif($choice eq 2){
		quota_2($obj);
	}elsif($choice eq 3){
		quota_3($obj);
	}elsif($choice eq 4){
		quota_4($obj);
	}elsif($choice eq 5){
		quota_5($obj);
	}elsif($choice eq 0){
		last;
	}
}

return 0;
}

sub quota_1(){
	my $obj = shift;
	system("clear");
	logo::logo();
	$obj->get();
	my $i = 2;
	print "1 - DEFAULT\n";
	my @tmp;
	$tmp[1] = 'DEFAULT';
	foreach my $key(sort(keys(%{$obj->{'quota'}}))){
		if($key eq "DEFAULT"){
			next;
		}
		print "$i - $key\n";
		$tmp[$i] = $key;
		$i++;
	}
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice lt $i and $choice gt 0){
		print "TempateID\tTemplateName\tcpuNum\tDiskSize\n";
		print "$tmp[$choice]\t$obj->{'quota'}->{$tmp[$choice]}->[0]\t$obj->{'quota'}->{$tmp[$choice]}->[1]\t$obj->{'quota'}->{$tmp[$choice]}->[2]\n";
	}else{
		print "Invalid Number is entered\n"
	}
	print "\nHit Enter\n";
	<STDIN>;

return 0;
}

sub quota_2(){
	my $obj = shift;
	system("clear");
	logo::logo();
	print <<EOF;
1 - Brief
2 - Detail
EOF
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	my $flag = 0;
	if($choice eq 1){
		$obj->getOrg('false');
		my @data = @{$obj->{'info'}};
		printf("%s\t%s\t%s\n","OrgId","TemplateId","TemplateName");
		foreach my $j(@data){
			printf("%s\t%s\t%s\n",@$j);
		}
		print "Enter OrgID >> ";
		my $choice = readline(STDIN);
		chomp($choice);
		foreach my $j(@data){
			if($j->[0] eq $choice){
				printf("%s\t%s\t%s\n","OrgId","TemplateId","TemplateName");
				printf("%s\t%s\t%s\n",@$j);
				$flag++;
			}elsif($choice eq ""){
			}
		}
		if($flag eq 0){
				print "Cannot find the OrgId in the list\n"
		}
	}elsif($choice eq 2){
		$obj->getOrg('true');
		my @data = @{$obj->{'info'}};
		printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n","OrgId","TemplateId","TemplateName","cpuNum","DiskSize(Total)","cpuNum(Use)","DiskSize(sysvol)","DiskSize(exdist)","Backup(sysvol)","Backup(exdisk)","Image");
		foreach my $j(@data){
			printf("%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",@$j);
		}
		print "Enter OrgID >> ";
		my $choice = readline(STDIN);
		chomp($choice);
		foreach my $j(@data){
			if($j->[0] eq $choice){
				printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n","OrgId","TemplateId","TemplateName","cpuNum","DiskSize(Total)","cpuNum(Use)","DiskSize(sysvol)","DiskSize(exdist)","Backup(sysvol)","Backup(exdisk)","Image");
				printf("%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",@$j);
				$flag++;
			}elsif($choice eq ""){
			}
		}
		if($flag eq 0){
				print "Cannot find the OrgId in the list\n"
		}
	}else{
		print "Invalid number is entered\n";
	}
	print "\nHit Enter\n";
	<STDIN>;

return 0;
}

sub quota_3(){
	my $obj = shift;
	system("clear");
	logo::logo();
	$obj->get();
	my $i = 2;
	print "1 - DEFAULT\n";
	my @tmp;
	$tmp[1] = 'DEFAULT';
	foreach my $key(sort(keys(%{$obj->{'quota'}}))){
		if($key eq "DEFAULT"){
			next;
		}
		print "$i - $key\n";
		$tmp[$i] = $key;
		$i++;
	}
	print "Enter number which you want to assign.\n>> ";
	my $tempID = readline(STDIN);
	chomp($tempID);
	print "Enter Contract ID where you want to assign the template to.\n>> ";
	my $cntID = readline(STDIN);
	chomp($cntID);
	my @moreID;
	if("$cntID" eq ""){
		print "Empty\n";
	}else{
		push(@moreID,$cntID);
		while(1){
			print "Any other Contract ID to assign the template to?\n>> ";
			my $tmp = readline(STDIN);
			chomp($tmp);
			if($tmp eq ""){
				last;
			}else{
				push(@moreID,$tmp);
			}
		}
		$obj->attach($tmp[$tempID],@moreID);
	}
	print "Hit Enter";
	<STDIN>;

return 0;
}

sub quota_4(){
	system("clear");
	logo::logo();
	my $obj = shift;
	print "Enter Org ID you want to apply DEFAULT template to\n";
	print ">>> ";
	my $orgID = readline(STDIN);
	chomp($orgID);
	
	$obj->getOrg('false');
	foreach my $i(@{$obj->{'info'}}){
		if($orgID eq $i->[0]){
			$obj->detach($i->[1],$i->[0]);
			print "Hit Enter";
			<STDIN>;
			return 0;
		}
	}
	print "Couldn't find the Org ID\n";
	print "Hit Enter";
	<STDIN>;

return 1;
}

sub quota_5(){
	my $obj = shift;
	system("clear");
	logo::logo();

return 0;
}

sub search(){
while(1){
	system("clear");
	logo::logo();
	print <<EOF;
1 - Find customer ID By Public IP address 
0 - Go back
EOF
	print "Choose number >> ";
	my $choice = readline(STDIN);
	chomp($choice);
	if($choice eq 1){
		search_1()
	}elsif($choice eq 0){
		last;
	}

}

return 0;
}

sub search_1(){
	print "Enter GIP >> ";
	my $gip = readline(STDIN);
	chomp($gip);
	my $obj = new validity();
	if($obj->ipaddress($gip)){
		open(IN,"$base_dir/exp/search_vsys_gip.exp $gip|") or die "FAILED!!";
		while(<IN>){
			print;
		}
		close(IN);
	}else{
		print "Invalid\n";
	}

	print "Hit Enter";
	<STDIN>;

return 0;
}

sub DomU_verbose(){
	system("clear");
	logo::logo();
	print "Enter Dom0 >> ";
	my $dom0 = readline(STDIN);
	chomp($dom0);
	my $obj = new validity();
	if($obj->dom0($dom0)){
		system("$base_dir/bin/domU_verbose.sh $dom0");
	}else{
		print "Boo\n";
	}
	print "\nHit Enter";
	<STDIN>;

return 0;
}

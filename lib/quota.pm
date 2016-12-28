#!/usr/bin/perl -I/usr/local/2nd_tools/lib

package quota;
sub new(){
	my $pkg = shift;
	bless{
		header => "Content-Type: application/x-www-form-urlencoded",
		auth => "Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==",
	},$pkg;
}

sub get(){
	my $self = shift;
	my $tempID = shift;
	$tempID = $self->url_encode($tempID);
	my %quota;
	if($tempID eq ""){
		open(IN,"curl -X GET -H '$self->{'header'}' -H '$self->{'auth'}' 'http://vsys-ap:7902/vsys/services/Quota/getTemplate?userId=vsysadmin' 2>/dev/null|") or die "FAILED!!";
	} else {
		open(IN,"curl -X GET -H '$self->{'header'}' -H '$self->{'auth'}' 'http://vsys-ap:7902/vsys/services/Quota/getTemplate?userId=vsysadmin&templateId=$tempID' 2>/dev/null|") or die "FAILED!!";
	}

	while(<IN>){
		chomp;
		my @tmp = /<template>(.*?)<\/template>/g;
		foreach my $tmp(@tmp){
			my @tmp2 = $tmp =~ m!<id>(.*)</id><name>(.*)</name><quota><cpuNum>(.*)</cpuNum><diskSize>(.*)</diskSize></quota>!;
			my $id = shift(@tmp2);
			$quota{"$id"=>[]};
			@{$quota{"$id"}} = @tmp2;
		}
	}
	close(IN);
	%{$self->{'quota'}} = %quota;
	while(my($key,$val) = each(%quota)){
		#print "key: $key\tName: $$val[0]\tCPU: $$val[1]\tDisk: $$val[2]\n";
	}

return 0;
}

sub attach(){
use env;

	my $self = shift;
	my $tempID = shift;
	$tempID = $self->url_encode($tempID);
	my @orgID = @_;
	my $base_dir = $env::base_dir;

	open(OUT,">$base_dir/tmp/quota_attach.txt") or die "FAILED!!";
	print OUT <<EOF;
<Request>
<userId>vsysadmin</userId>
<templateId>$tempID</templateId>
<orgIds>
EOF
	foreach my $orgID(@orgID){
		print OUT "<id>$orgID</id>\n"
	}
	print OUT <<EOF;
</orgIds>
</Request>
EOF
	close(OUT);
	open(IN,"curl -X POST -H 'Content-Type: application/xml' -H '$self->{'auth'}' -d \@$base_dir/tmp/quota_attach.txt 'http://vsys-ap:7902/vsys/services/Quota/attach' 2>/dev/null|");
	while(<IN>){
		chomp;
		if(/SUCCESS/){
			print "SUCCESS\n";
		}else{
			print "Error detected. Please contact 2nd line support\n";
		}
	}

return 0;
}

sub detach(){
use env;
	my $self = shift;
	my $tempID = shift;
	$tempID = $self->url_encode($tempID);
	my @orgID = @_;
	my $base_dir = $env::base_dir;

	open(OUT,">$base_dir/tmp/quota_detach.txt") or die "FAILED!!";
	print OUT <<EOF;
<Request>
<userId>vsysadmin</userId>
<templateId>$tempID</templateId>
<orgIds>
EOF
	foreach my $orgID(@orgID){
		print OUT "<id>$orgID</id>\n";
	}
	print OUT <<EOF;
</orgIds>
</Request>
EOF
	close(OUT);
	open(IN,"curl -X POST -H 'Content-Type: application/xml' -H '$self->{'auth'}' -d \@$base_dir/tmp/quota_detach.txt 'http://vsys-ap:7902/vsys/services/Quota/detach' 2>/dev/null|");
	while(<IN>){
		chomp;
		if(/SUCCESS/){
			print "SUCCESS\n";
		}else{
			print "Error detected. Please contact 2nd line support\n";
		}
	}

return 0;
}

sub delete(){
	my $self = shift;
	my $tempID = shift;
	$tempID = $self->url_encode($tempID);

	open(IN,"curl -X GET -H '$self->{'header'}' -H '$self->{'auth'}' 'http://vsys-ap:7902/vsys/services/Quota/removeTemplate?userId=vsysadmin&templateId=$tempID' 2>/dev/null|") or die "FAILED!!";
	close(IN);

return 0;
}

sub create(){
	my $self = shift;
	my $tempID = shift;
	my $tempName = shift;
	my $cpuNum = shift;
	my $diskSize = shift;
	$tempID = $self->url_encode($tempID);
	$tempName = $self->url_encode($tempName);

	open(IN,"curl -X GET -H '$self->{'header'}' -H '$self->{'auth'}' 'http://vsys-ap:7902/vsys/services/Quota/setTemplate?userId=vsysadmin&templateId=$tempID&templateName=$tempName&cpuNum=$cpuNum&diskSize=$diskSize' 2>/dev/null|") or die "FAILED!!";
	close(IN);

return 0;
}

sub getOrg(){
	my $self = shift;
	my $detail = shift;
	my %data;

	if($detail eq ""){
		return 1;
	}

	$/ = "</org>";
	my @data = ();
	open(IN,"curl -X GET -H '$self->{'header'}' -H '$self->{'auth'}' 'http://vsys-ap:7902/vsys/services/Quota/get?userId=vsysadmin&detail=$detail' 2>/dev/null|") or die "FAILED!!";
	my $i = 0;
	if($detail eq 'true'){
		while(<IN>){
			@{$data[$i]} = m!<org><orgId>(.*?)</orgId><templateId>(.*?)</templateId><templateName>(.*?)</templateName><quota><cpuNum>(.*?)</cpuNum><diskSize>(.*?)</diskSize></quota><usage><cpuNum>(.*?)</cpuNum><diskSize><sysvol>(.*?)</sysvol><exdisk>(.*?)</exdisk><backup><sysvol>(.*?)</sysvol><exdisk>(.*?)</exdisk></backup><image>(.*?)</image></diskSize></usage></org>!;
			$i++;
		}
	}elsif($detail eq 'false'){
		while(<IN>){
			@{$data[$i]} = m!<org><orgId>(.*?)</orgId><templateId>(.*?)</templateId><templateName>(.*?)</templateName></org>!;
			$i++;
		}
	}
	close(IN);
	$/ = "\n";
	pop(@data);
	@{$self->{'info'}} = @data;

return 0;
}

sub url_encode(){
	my $self = shift;
	my $str = shift;

	$str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
	$str =~ tr/ /+/;

return $str;
}

;1;

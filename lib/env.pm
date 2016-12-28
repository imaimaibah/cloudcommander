#!/usr/bin/perl

package env;
our $base_dir = "/usr/local/2nd_tools";

umask(0000);

our $region = "STGV2";

our ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime(time());
$sec= sprintf("%02d", $sec);
$min= sprintf("%02d", $min);
$hour = sprintf("%02d", $hour);
$mday = sprintf("%02d", $mday);
$mon = sprintf("%02d",++$mon);
$year += 1900;
our $today = $year.$mon.$mday;
our $now = "$hour$min$sec";
our $region_num;
our $ipcom;
our $region_base;

our @eigo_mon = convertMonth($mon);

if($region eq "JP01"){
	$region_num = "01011";
	$region_base = 0;
	$ipcom = "10.3.1.40";
	$ent_centos = "10.3.0.130";
}elsif($region eq "AU01"){
	$region_num = "02011";
	$region_base = 4;
	$ipcom = "10.7.1.40";
	$ent_centos = "10.7.0.130";
}elsif($region eq "SG01"){
	$region_num = "03011";
	$region_base = 8;
	$ipcom = "10.11.1.40";
	$ent_centos = "10.11.0.130";
}elsif($region eq "US01"){
	$region_num = "04011";
	$region_base = 12;
	$ipcom = "10.15.1.40";
	$ent_centos = "10.15.0.130";
}elsif($region eq "UK01"){
	$region_num = "05011";
	$region_base = 16;
	$ipcom = "10.19.1.40";
	$ent_centos = "10.19.0.130";
}elsif($region eq "DE01"){
	$region_num = "06011";
	$region_base = 20;
	$ipcom = "10.23.1.40";
	$ent_centos = "10.23.0.130";
}elsif($region eq "JP02"){
	$region_num = "07011";
	$region_base = 24;
	$ipcom = "10.27.8.14";
	$ent_centos = "10.27.0.130";
}elsif($region eq "STGV1"){
	$region_num = "01011";
	$region_base = 0;
	$ipcom = "10.3.1.200";
}elsif($region eq "STGV2"){
	$region_num = "01011";
	$region_base = 0;
	$ipcom = "10.3.1.24";
}else{
	print "Unknown Region: Exit the process\n";
	exit 1;
}

sub time_renew(){
	( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime(time())  ;
	$sec= sprintf("%02d", $sec);
	$min= sprintf("%02d", $min);
	$hour = sprintf("%02d", $hour);
	$mday = sprintf("%02d", $mday);
	$mon = sprintf("%02d",++$mon);
	$year += 1900;
	$today = $year.$mon.$mday;
	$now = $hour.$min.$sec;

return 0;
}

sub convertMonth(){
	my $temp = shift;
	my @mon;
	$mon[1] = "1";
	if($temp eq "01" or $temp eq 1){
		$mon[0] = "January";
		$mon[2] = "31";
		$mon[3] = "Jan";
	}elsif($temp eq "02" or $temp eq 2){
		$mon[0] = "February";
		if(( $env::year % 4 ) eq 0 and ( $env::year % 100 ) ne 0 or ( $env::year % 400 ) eq 0){
			$mon[2] = "29";
		}else{
			$mon[2] = "28";
		}
		$mon[3] = "Feb";
	}elsif($temp eq "03" or $temp eq 3){
		$mon[0] = "March";
		$mon[2] = "31";
		$mon[3] = "Mar";
	}elsif($temp eq "04" or $temp eq 4){
		$mon[0] = "April";
		$mon[2] = "30";
		$mon[3] = "Apr";
	}elsif($temp eq "05" or $temp eq 5){
		$mon[0] = "May";
		$mon[2] = "31";
		$mon[3] = "May"
	}elsif($temp eq "06" or $temp eq 6){
		$mon[0] = "June";
		$mon[2] = "30";
		$mon[3] = "Jun";
	}elsif($temp eq "07" or $temp eq 7){
		$mon[0] = "July";
		$mon[2] = "31";
		$mon[3] = "Jul";
	}elsif($temp eq "08" or $temp eq 8){
		$mon[0] = "August";
		$mon[2] = "31";
		$mon[3] = "Aug";
	}elsif($temp eq "09" or $temp eq 9){
		$mon[0] = "September";
		$mon[2] = "30";
		$mon[3] = "Sep";
	}elsif($temp eq "10"){
		$mon[0] = "October";
		$mon[2] = "31";
		$mon[3] = "Oct";
	}elsif($temp eq "11"){
		$mon[0] = "November";
		$mon[2] = "30";
		$mon[3] = "Nov";
	}elsif($temp eq "12"){
		$mon[0] = "December";
		$mon[2] = "31";
		$mon[3] = "Dec";
	}

return @mon;
}



package create_list;
sub new{
  my $pkg = shift;
  bless{
	data => [],
  },$pkg;
}

sub eternus(){
	$self = shift;
	$data = $self->{'data'};
	@file = glob("$base_dir/data/island?_eternus/$region");
	foreach my $file(@file){
		open(IN, "$file") or die "Cannot read a file: $file";
		while(my $line=readline(IN)){
			chomp($line);
			push(@$data,split(/\t/, $line));
			pop(@$data);
		}
		close(IN);
	}
		
return 0;
}

sub primergy_irmc(){
	$self = shift;
	$data = $self->{'data'};
	@file = glob("$base_dir/data/island?_pserver/$region");
	foreach my $file(@file){
		open(IN, "$file") or die "Cannot read a file: $file";
		while(my $line=readline(IN)){
			chomp($line);
			my @temp = split(/\t/, $line);
			push(@$data,$temp[2]);
		}
		close(IN);
	}

return 0;
}

sub primergy(){
	$self = shift;
	$data = $self->{'data'};
	open(IN,"$base_dir/exp/node_list.exp all|") or die "FAILED";
	while(<IN>){
		my @tmp = split(/,/);
		$tmp[0] =~ s/"//g;
		if($tmp[0] =~ /ps[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
			$tmp[1] =~ s/"//g;
			push(@$data,$tmp[1]);
		}
	}
	close(IN);

return 0;
}

package password;
sub new {
	my $pkg = shift;
	my $id = `id -un`;
	chomp($id);
	
	bless{
		userid => $id,
		data => [],
	},$pkg;
}

sub Pass_change(){
	$self = shift;
	my $cur_pass;
	my $pass;
	my $i=0;
	if($self->firstTime()){
		while($i<3){
		print "Current password: ";
			system("stty -echo");
			$cur_pass = readline(STDIN);
			chomp($cur_pass);
			system("stty echo");
			print "\n";
			if($cur_pass eq ""){
				print "Password cannot be empty\n";
				next;
			}elsif(!$self->check($cur_pass)){
				print "Wrong current password\n";
				$i++;
				next;
			}else{
				last;
			}
		}
		if($i eq 3){
			print "Please consider to use a different password.\n";
			return 128;
		}
	}
	while(1){
		print "New Password: ";
		system("stty -echo");
		$pass = readline(STDIN);
		chomp($pass);
		system("stty echo");
		print "\n";
		if($pass eq ""){
			print "Password cannot be empty\n";
			next;
		}elsif($self->howold($pass)){
			print "The password you entered is the same as the old password.\n";
			next;
		}elsif(!$self->policy($pass)){
			print "The password must meet the password policy.\n";
			next;
		}else{
			print "Confirm: ";
			system("stty -echo");
			my $con_pass = readline(STDIN);
			chomp($con_pass);
			system("stty echo");
			print "\n";
			if("$pass" eq "$con_pass"){
				last;
			}else{
				print "Password does not match\n";
				next;
			}
		}
	}

	system("$base_dir/exp/passwd_change.exp $self->{'userid'} $pass > $base_dir/log/exp/passwd.log 2>&1");
	my $tmp = $?;
	my $ret = $tmp >> 8;
	if($ret eq 0){
		$self->update($pass);
	}else{
		print "Failed\n";
	}

return $ret;
}

sub firstTime(){
	my $self = shift;
	open(IN, "$base_dir/log/audit/passwd") or die "Failed!!";
	while(<IN>){
		chomp;
		my @tmp = split(/:/);
		if($tmp[0] eq "$self->{'userid'}"){
			return 1;
		}
	}
	close(IN);

	open(OUT,">>$base_dir/log/audit/passwd") or die "Failed!!";
	print OUT "$self->{'userid'}:".time();
	close(OUT);

return 0;
}

sub policy(){
	my $self = shift;
	my $pass = shift;
	my $length = length($pass);
	

	if($pass =~ /[0-9]/ and $pass =~ /[a-zA-Z]/ and $length > 7 ){
		return 1;
	}
return 0;
}

sub howold(){
	my $self = shift;
	my $passwd = shift;
	my $data = ();
	open(IN,"$base_dir/log/audit/passwd");
	my $i = 0;
	while(<IN>){
		chomp;
		@{$self->{'data'}->[$i]} = split(/:/);
		$i++;
	}
	close(IN);
	foreach my $line(@{$self->{'data'}}){
		if($line->[0] eq $self->{'userid'}){
			for(my $i=2;$i<@{$line};$i++){
				if($self->dec($passwd,$line->[$i])){
					return 1;
				}
			}
		}
	}

return 0;
}

sub check(){
	my $self=shift;
	my $passwd = shift;
	open(IN,"$base_dir/log/audit/passwd");
	my $i = 0;
	while(<IN>){
		chomp;
		@{$self->{'data'}->[$i]} = split(/:/);
		$i++;
	}
	close(IN);
	foreach my $line(@{$self->{'data'}}){
		if($line->[0] eq $self->{'userid'}){
			if($self->dec($passwd,$line->[2])){
				return 1;
			}
		}
	}

return 0;
}

sub dec(){
	my $self=shift;
	my $new_pass=shift;
	my $old_pass=shift;
	my @seed = split(/\$/,$old_pass);
	my $tmp = `openssl passwd -1 -salt $seed[2] $new_pass 2>/dev/null`;
	chomp($tmp);
	if($tmp eq $old_pass){
		return 1;
	}

return 0;
}

sub update(){
	my $self = shift;
	my $pass = shift;
	my $update_time = time();
	my $new_pass = `openssl passwd -1 $pass 2>/dev/null`;
	chomp($new_pass);
	$self->firstTime();
	eval{
		local $SIG{ALRM} = sub{ die "time out"};
		open(IN,"$base_dir/log/audit/passwd");
		open(OUT,">$base_dir/log/audit/passwd-");
		alarm(5);
		flock(OUT,2) or die;
		alarm(300);
		while(<IN>){
			chomp;
			if(/$self->{'userid'}/){
				my @tmp = split(/:/);
				shift(@tmp);
				shift(@tmp);
				if(@tmp ge 4){
					pop(@tmp);
				}
				$_ = join(":","$self->{'userid'}","$update_time","$new_pass",@tmp);
			}
			print OUT "$_\n";
		}
		close(OUT);
		close(IN);
		rename("$base_dir/log/audit/passwd-","$base_dir/log/audit/passwd");
		alarm(0);
	};
	if($@ =~ /time out/){
		print "Timeout occurred. Somebody is using the same script to change his/her password.\n";
	}

return 0;
}

package chk_validity;
sub new {
	my $pkg = shift;
	bless{},$pkg;
}

sub chk_pserv(){
	my $self = shift;
	my $serv = shift;
	my $ret;
	open(IN, "$base_dir/data/islanda_pserver/$region") or die "Cannot open the file";
	while(<IN>){
		chomp;
		my @data = $_=~ /[^ \t]+/g;
		pop(@data);
		$ret = grep {$_ eq $serv} @data;
		if($ret > 0){
			return $ret;
		}
	}
	close(IN);

return 0;
}

sub chk_iRMC(){
	my $self = shift;
	my $irmc = shift;
	my $option = shift;
	foreach my $island(@$option){
		if($island =~ /island.-cbrm/){
			my @tmp = split(/-/,$island);
			my $ret;
			open(IN, "$base_dir/data/$tmp[0]_pserver/$region") or die "FAILED!!";
			while(<IN>){
				chomp;
				my @data = $_ =~ /[^ \t]+/g;
				$ret = grep {$_ eq $irmc} @data;
				if($ret > 0){
					return $data[2];
				}
			}
			close(IN);
		}
	}

return 0;
}

sub chk_eternus(){
	my $self = shift;
	my $eternus = shift;
	my $option = shift;
	foreach my $island(@$option){
		if($island =~ /island.-cbrm/){
			my @tmp = split(/-/,$island);
			my $ret;
			open(IN, "$base_dir/data/$tmp[0]_eternus/$region") or die "FAILED!!";
			while(<IN>){
				chomp;
				my @data = $_ =~ /[^ \t]+/g;
				$ret = grep {$_ eq $eternus} @data;
				if($ret > 0){
					return $ret;
				}
			}
			close(IN);
		}
	}

return 0;
}


package logo;
sub logo(){
	my $ver = `cat $base_dir/version`;
	chomp($ver);
	print <<EOF;
#############################################
###            First Line Shell           ###
###                  Written by Shin Imai ###
###   Current Ver. $ver                    ###
#############################################
EOF
}
	

;1;

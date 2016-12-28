#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use Time::Local;
use env;
use auth;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
$user="shin.imai";
my $auth = new auth($user);
my $cgi = new web_cgi;
my $obj =  new JSON();
my $data = ();
$cgi->hash($ENV{'QUERY_STRING'});

print "Content-type: application/json\n\n";
if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	print $obj->encode($data);
	exit;
}

my $start_date = $cgi->{'start'};
my $end_date = $cgi->{'end'};
my $hour = $cgi->{'hour'};

### DIR ###
my @date;
if(($start_date ne "" and $end_date eq "") or $start_date eq $end_date){
	@date = sort { $a <=> $b } getDir($start_date);
}elsif($start_date ne "" and $end_date ne ""){
	do{
		push(@date,$start_date.$hour);
		$start_date = nextday($start_date);
	}while($end_date ne $start_date);
	push(@date,$start_date.$hour);
}else{
	@date = sort { $a <=> $b } getDir();
}
for my $date(@date){
	my $category = $date;
	$category =~ s!(....)(..)(..)(..)!$1/$2/$3 $4 hour!;
	push(@{$data->{'category'}},$category);
}


### MAIN ###
$data->{'lserver'} = {};
lserver($data->{'lserver'});
$data->{'eco_lserver'} = {};
eco_lserver($data->{'eco_lserver'});
$data->{'vdisk'} = {};
vdisk($data->{'vdisk'});
$data->{'vmtype'} = {};
vmtype($data->{'vmtype'});
$data->{'middle'} = {};
middle($data->{'middle'});
$data->{'os'} = {};
os($data->{'os'});
print $obj->encode($data);


### Functions ###
sub lserver(){
my $data = shift;
my $tmp = ();
my $i=0;
$data->{'xText'} = "LSERVER";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "/data/trend/$date/lserver.log"){
		next;
	}
	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			if($tmp[3] eq 'UNEXPECTED_STOP'){
				$tmp[3] = 'STOPPED';
			}
			$tmp->{$tmp[3]}->[$i] += 1;
		}
	}
	close(IN);
	$i++;
}

$i=0;
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = $key;
	foreach my $val1(@$val){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}

sub vdisk(){
my $data = shift;
my $tmp = ();
my $i=0;
$data->{'xText'} = "VDISK";
$data->{'yText'} = "Giga Bytes";
foreach my $date(@date){
	if(!-e "/data/trend/$date/lserver.log"){
		next;
	}
	open(IN, "/data/trend/$date/vdisk.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			$tmp->{$tmp[2]}->[$i] += $tmp[3];
		}
	}
	close(IN);

	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			$tmp->{'SYSVOL'}->[$i] += $tmp[5];
		}
	}
	close(IN);

	open(IN, "/data/trend/$date/image.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			$tmp->{'IMAGE'}->[$i] += $tmp[3];
		}
	}
	$i++;
	close(IN);
}

$i=0;
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = $key;
	foreach my $val1(@$val){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="GB";

}

sub getDir(){
	my $date = shift;
	my $end = shift;
	if($date eq ""){
		$date = $env::today;
	}
my @dir;
opendir(DIR,"/data/trend");
foreach my $dir(readdir DIR){
	if($dir ne ".." and $dir ne "." and -d "/data/trend/$dir" and $dir eq $date){
		opendir(DIR2,"/data/trend/$dir");
		foreach my $dir2(readdir DIR2){
			if($dir2 ne ".." and $dir2 ne "." and -d "/data/trend/$dir/$dir2"){
				push(@dir,"$dir/$dir2");
			}
		}
		closedir(DIR2);
	}
	#if(-d "/data/trend/$dir" and $dir =~ /$date../){
	#	push(@dir,$dir);
	#}
}
closedir(DIR);

return @dir;
}

sub nextday(){
	my $start = shift;

	my ($start_year,$start_month,$start_day) = $start =~ /(....)(..)(..)/;
	my $next = timelocal(0,0,0,$start_day,$start_month-1,$start_year-1900)+86400;
	
	my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime($next);

	$sec= sprintf("%02d", $sec);
	$min= sprintf("%02d", $min);
	$hour = sprintf("%02d", $hour);
	$mday = sprintf("%02d", $mday);
	$mon = sprintf("%02d",++$mon);
	$year += 1900;

return $year.$mon.$mday;
}

sub vmtype(){
my $data = shift;
my $tmp = ();
my $i=1;
$data->{'xText'} = "VM TYPE";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "/data/trend/$date/lserver.log"){
		next;
	}
	open(IN,"/data/trend/$date/lst.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[A-Z]{3}-[A-Z]{2}-[0-9]{4}-[0-9]{4}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			push(@{$tmp->{$tmp[1]}},$tmp[3]);
		}
	}
	close(IN);
	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			if($tmp[6] eq 'firewall'){
				$tmp->{$tmp[6]}->[0] = "Firewall";
			}elsif(isslb($tmp[4],$date)){
				$tmp->{$tmp[6]}->[0] = "SLB";
			}
			$tmp->{$tmp[6]}->[$i] += 1;
		}
	}
	close(IN);
	$i++;
}

$i=0;
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = shift(@{$val});
	foreach my $val1(@$val){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}

sub os(){
my $data = shift;
my $tmp = ();
my $tmp1 = ();
my $i=0;
$data->{'xText'} = "OS TYPE";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "/data/trend/$date"){
		next;
	}
	open(IN,"/data/trend/$date/software.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/SW[0-9]{8}/){
			my @tmp = $_ =~ /[^\s|]+/g;
			$tmp->{'os'}->{$tmp[0]} = $tmp[1];
		}
	}
	close(IN);
	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			$tmp->{$tmp->{'os'}->{$tmp[4]}}->[$i] += 1;
		}
	}
	close(IN);
	$i++;
}

$i=0;
delete($tmp->{'os'});
while(my($key,$val)=each(%$tmp)){
	if($key eq ""){
		next;
	}
	$data->{'series'}->[$i]->{'name'} = $key;
	foreach my $val1(@{$val}){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}

sub middle(){
my $data = shift;
my $tmp = ();
my $tmp1 = ();
my $i=0;
$data->{'xText'} = "VM TYPE";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "/data/trend/$date"){
		next;
	}
	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			$tmp1->{$tmp[4]}->[$i] += 1;
		}
	}
	close(IN);
	open(IN,"/data/trend/$date/middle.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/SW[0-9]{8}/){
			my @tmp = $_ =~ /[^|]+/g;
			foreach my $w(@tmp){
				$w =~ s/^[\s]*(.*?)/$1/;
				$w =~ s/(.*?)[\s]*$/$1/;
			}
			$tmp->{$tmp[1]}->[0] = $tmp[3];
			$tmp->{$tmp[1]}->[1]->[$i] += $tmp1->{$tmp[2]}->[$i];
		}
	}
	close(IN);
	$i++;
}

$i=0;
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = $val->[0];
	foreach my $val1(@{$val->[1]}){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}

sub isslb($){
	my $image_id = shift;
	my $date = shift;
	open(LINK,"/data/trend/$date/software_link.log") or die "FAILED";
	while(<LINK>){
		chomp;
		s/\r//g;
		if(/ipcom/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			if($tmp[1] eq $image_id and $tmp[0] =~ /ipcom_slb/){
				return 1;
			}
		}
	}
	close(LINK);

return 0;
}

sub eco_lserver(){
my $data = shift;
my $tmp = ();
my $i=0;
$data->{'xText'} = "LSERVER";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "/data/trend/$date/lserver.log"){
		next;
	}
	open(IN,"/data/trend/$date/lst.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[A-Z]{3}-[A-Z]{2}-[0-9]{4}-[0-9]{4}/){
			my @tmp = $_ =~ /[^\s|]+/g;
			$tmp->{'type'}->{$tmp[1]} = $tmp[2];
		}
	}
	close(IN);
	open(IN,"/data/trend/$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			if($tmp[3] eq 'UNEXPECTED_STOP'){
				$tmp[3] = 'STOPPED';
			}
			$tmp->{$tmp[3]}->[$i] += $tmp->{'type'}->{$tmp[6]};
		}
	}
	close(IN);
	$i++;
}

$i=0;
delete($tmp->{'type'});
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = $key;
	foreach my $val1(@$val){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}

close(DEBUG);


#!/usr/bin/perl -I/usr/local/2nd_tools/lib


use env;
use auth;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $cgi = new web_cgi;
my $obj =  new JSON();
my $data = ();
$cgi->hash($ENV{'QUERY_STRING'});
my $top = $cgi->{'top'};
my $xText = "VM Type";
my $yText = "Number of VMs";

print "Content-type: application/json\n\n";
if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	print $obj->encode($data);
	exit;
}

open(IN,"$base_dir/exp/serv_type.exp|");
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}.*$/){
		my @tmp = $_ =~ /[^\s|]+/g;
		$data->{$tmp[0]}->{$tmp[1]} = $tmp[2];
	}
}
close(IN);
my $result;
@{$result->{'category'}} = sortOrg($data);

my @os;

while(my($key,$val)=each(%$data)){
	while(my($key1,$val1)=each(%$val)){
		push(@os,$key1);
	}
}

@os = grep(!$tmp{$_}++,@os);


$result->{"xText"} = $xText;
$result->{"yText"} = $yText;

for(my $i=0;$i<@os;$i++){
	$result->{'series'}->[$i]->{'name'} = $os[$i];
	my $l=0;
	foreach my $org(@{$result->{'category'}}){
		if($data->{$org}->{$os[$i]} eq ""){
			push(@{$result->{'series'}->[$i]->{'data'}}, 0);
		}else{
			push(@{$result->{'series'}->[$i]->{'data'}}, $data->{$org}->{$os[$i]}+0);
		}
		$result->{'series'}->[$i]->{'stack'} = $l++;;
		if($l>$top-1){
			last;
		}
	}
}

$result->{'unit'} = "";
$result->{'type'} = "column";

print $obj->encode($result);

sub sortOrg(){
	my $data = shift;
	my @org;
	my %tmp;
	while(my($key,$val)=each(%$data)){
		while(my($key1,$val1)=each(%$val)){
			$tmp{$key} += $val1;
		}
	}

	foreach my $key(sort {$tmp{$b} <=> $tmp{$a}} keys(%tmp)){
		push(@org,$key);
	}

	return @org;
}

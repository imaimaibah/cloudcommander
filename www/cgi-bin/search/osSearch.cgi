#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(validity web_cgi);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $data = ();
my $validity = new validity;

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}elsif(!$validity->org($cgi->{'org'}) and ! $validity->vsys($cgi->{'org'})){
	print "{\"result\":\"Invalid ID entered\"}";
	exit;
}else{
	$data->{'result'} = 'SUCCESS';
}


open(IN,"$base_dir/exp/search_os.exp $cgi->{'org'}|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4}/){
		shori($data,$_);
	}
}
close(IN);

sub shori($){
	my $data = shift;
	my $line = shift;
	my @yoso;

	@yoso = $line =~ /[^|]+/g;

foreach my $yoso(@yoso){
	$yoso =~ s/^[\s\t]+(.+?)[\s\t]+$/$1/;
}

	my $server_id = shift(@yoso);

@{$data->{'org'}->{$server_id}} = @yoso;

}

my $obj = new JSON();
print $obj->encode($data);

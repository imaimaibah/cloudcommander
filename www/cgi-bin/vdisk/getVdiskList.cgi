#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use func qw(web_cgi);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $obj = new auth($user);
my $audit = new audit_web();
my $cgi = new web_cgi;
my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);

print "Content-type: txt/html\n\n";

if(!$obj->_auth()){
	print "<Response><status>Auth failed</status></Response>\n";
}else{
	if($cgi->{'vdisk'} eq ""){
		open(IN,"curl -k -X GET -H \"Authorization: Basic cm9vdDpzb3B4ZW4=\" -H \"application/x-www-form-urlencoded\" https://islanda-cbrm:23461/disks 2>/dev/null|");
		while(<IN>){
			if(/<table>/){
				print "<table border=\"1px\">\n";
			}elsif(/<a href="\/disks\/(.*?)">show<\/a>/){
				my $vdisk = $1;
				print "<td><a href=/vdisk/index.html?vdisk=$vdisk>show</a></td>\n";
			}else{
				print;
			}
		}
		close(IN);
	}else{
		open(IN,"curl -k -X GET -H \"Authorization: Basic cm9vdDpzb3B4ZW4=\" -H \"application/x-www-form-urlencoded\" https://islanda-cbrm:23461/disks/$cgi->{'vdisk'} 2>/dev/null|");
		while(<IN>){
			if(/<a href="\/disks">back<\/a>/){
				print "<a href=\"/vdisk/index.html\">back</a>\n"
			}else{
				print;
			}
		}
		close(IN);
	}
}

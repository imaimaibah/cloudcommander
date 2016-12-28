#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use audit qw(audit_web);
use auth;
use func qw(validity);
use JSON;
use env;

my $user = $ENV{'AUTHENTICATE_UID'};
my $base_dir = $env::base_dir;
my $Get = $ENV{'QUERY_STRING'};
my $ipcom = $env::ipcom;
my $auth = new auth($user);
my $audit = new audit_web();
my $json = new JSON();
my $validity = new validity();
my $data = ();
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});
my $hash = $json->decode($Post);

my @userList;
foreach my $address(@{$hash->{'userList'}}){
	if($address ne ""){
		if(!$validity->fmail($address)){
			push(@{$data->{'invalid'}},$address);
		}else{
			push(@userList,$address);
		}
	}
}
$data->{'result'} = "";
print "Content-type: application/json\n\n";
if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	my $ret;
	ldapReset();
	$ret = sslReset();

	if($ret eq 0){
		$data->{'result'} = "SUCCESS";
		my $log = <<EOF;
$ENV{'REQUEST_URI'}
These IDs were created by $user.
@userList
EOF
		$audit->log($user,$log);
	}else{
		$data->{'result'} = "FAILED";
	}

}

print $json->encode($data);

close(DEBUG);

sub ldapReset(){
	open(OUT,"|$base_dir/exp/resetLDAPAccount.exp");
	createLdapPass(OUT,@userList);
	close(OUT);
}

sub sslReset(){
	my $ret;
	if($#userList gt -1){
		open(OUT,"|$base_dir/exp/resetSSLAccount.exp $ipcom 'nt\%$env::region_num'");
		createPass(OUT,@userList);
		close(OUT);
		$ret = 0;
		foreach my $operator(@userList){
			open(SMTP,"|$base_dir/pl/smtp.pl -f GCP_administrator\@jp.fujitsu.com -t $operator -b c3s-global-suppport-2nd\@ml.css.fujitsu.com -s 'SSL-VPN password reset'> /dev/null");
			print SMTP "Your password SSL-VPN has been initialized by $user.";
			close(SMTP);
		}
	}else{
		$ret = 1;
	}

return $ret
}

sub createLdapPass($@){
		my $fhandle = shift;
		my @val = @_;
		my $length = 8;
		my @letters = ('a'..'z', 'A'..'Z', 0..9);
		foreach my $j(@val){
  		$pass .= $letters[int(rand(@letters))] for(1 .. $length);
			print $fhandle "$j,$pass\n";
			open(SMTP,"|$base_dir/pl/smtp.pl -f 'GCP_Administrator\@jp.fujitsu.com' -t '$j' -b 'c3s-global-suppport-2nd\@ml.css.fujitsu.com' -s 'Notice:Cloud Commander Account reset' >/dev/null 2>&1") or &debug("FAILED!!");
			print SMTP <<EOF;
Your Account has been reset.
The initial password is;
$pass
EOF
			$pass="";
			close(SMTP);
		}
}

sub createPass($@){
	my $fhandle = shift;
	my @val = @_;
	foreach my $pass(@val){
		print $fhandle "$pass,";
		$pass =~ s/@/#/;
		$pass =~ s/\./\$/g;
		$pass .= "!$env::region_num";
		print $fhandle "$pass\n";
	}

return 0;
}

sub debug($){
	open(DEBUG1,">/tmp/debug.log");
	print DEBUG1 $_."\n";
	close(DEBUG1);
	exit;
}


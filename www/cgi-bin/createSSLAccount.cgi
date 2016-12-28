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
print "Content-type: application/json\n\n";
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});
my $hash = $json->decode($Post);

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	print $json->encode($data);
	exit;
}elsif($auth->{'group'} ne "2nd"){
	while(my($key,$val)=each(%$hash)){
		if($key eq "2nd"){
			$data->{'result'} = "You are not authorized to create 2nd line accounts.";
			print $json->encode($data);
			exit;
		}
	}
}elsif(!duplicateCheck($hash)){
	$data->{'result'} = "Duplicated account found";
	print $json->encode($data);
	exit;
}

main();
#audit();

sub main(){
my @userList;
while(my($key,$val)=each(%$hash)){
	if($key eq "tatebayashiCE"){
		next;
	}
	foreach my $user(@$val){
		push(@userList,$user);
	}
}

#foreach my $address(@{$hash->{'userList'}}){
#	if($address ne ""){
#		if(!$validity->fmail($address)){
#			push(@{$data->{'invalid'}},$address);
#		}else{
#			push(@userList,$address);
#		}
#	}
#}

	if(@userList > 0){
		my $ret;
		$ret = create(@userList);
	}

	#	if($ret eq 0){
			ldapCreate($hash);
			groupAdd($hash);
			_groupAdd($hash);
			my $log = <<EOF;
$ENV{'REQUEST_URI'}
START NEW TASK
These IDs have been created by $user.
@userList
COMPLETE NEW TASK
EOF
			$audit->log($user,$log);
	#	}else{
	#		$data->{'result'} = "FAILED";
	#	}
	#}
	$data->{'result'} = "SUCCESS";

print $json->encode($data);
}

sub create(){
	my @userList = @_;
	my $ret = 1;
	#if($#userList gt -1){
		open(OUT,"|$base_dir/exp/createSSLAccount.exp $ipcom 'nt\%$env::region_num'");
		createPass(OUT,@userList);
		close(OUT);
		$ret = 0;
		foreach my $operator(@userList){
			open(SMTP,"|$base_dir/pl/smtp.pl -f GCP_administrator\@jp.fujitsu.com -t $operator -b c3s-global-suppport-2nd\@ml.css.fujitsu.com -s 'SSL-VPN account creation' > /dev/null");
			print SMTP "Your account for SSL-VPN has been created by $user.";
			close(SMTP);
		}
	#}else{
	#	$ret = 1;
	#}

return $ret
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

sub ldapCreate(){
	my $ldap = shift;
	my @letters = ('a'..'z', 'A'..'Z', 0..9);
	my $length = 8;
	open(OUT,"|$base_dir/exp/createLDAPAccount.exp") or die "FAILED";
	while(my($key,$val)=each(%$ldap)){
		my($ldapgroup,$confidential,$login) = getprivilege($key);
		foreach my $j(@$val){
  		$pass .= $letters[int(rand(@letters))] for(1 .. $length);
			print OUT "$j,$pass,$ldapgroup,$confidential,$login\n";
			open(SMTP,"|$base_dir/pl/smtp.pl -f 'GCP_Administrator\@jp.fujitsu.com' -t '$j' -b 'c3s-global-suppport-2nd\@ml.css.fujitsu.com' -s 'Notice:Cloud Commander Account Created' >/dev/null 2>&1") or die "FAILED!!";
			print SMTP <<EOF;
Your Account has been Created.
The initial password is;
$pass

Please chaging your initial password as soon as you can by accessing C2(Cloud Commander).

To access the above URL, you require SSL-VPN connection.
EOF
			$pass = "";
			close(SMTP);
		}
	}
	close(OUT);
}

sub groupAdd(){
	my $user = shift;
	my %group;
	open(IN,"/usr/local/2nd_tools/lib/group");
	while(<IN>){
		chomp;
		my @tmp = split(/:/);
		my $group = shift(@tmp);
		@{$group{$group}} = @tmp;
		@tmp=();
	}
	close(IN);

	while(my($key,$val)=each(%$user)){
		foreach my $j(@$val){
			my $user = $j;
			$user =~ s/@.+//;
			push(@{$group{$key}},$user);
		}
	}

	open(OUT,">/usr/local/2nd_tools/lib/group");
	while(my($key,$val)=each(%group)){
		print OUT $key;
		for(my $i=0;$i<@$val;$i++){
			print OUT ":".$val->[$i];
		}
		if($group eq $key){
			print OUT ":$user\n";
		}else{
			print OUT "\n";
		}
	}
	close(OUT);
}

sub _groupAdd(){
	my $user = shift;
	open(IN,"/data/accounts/user") or die "FAILED";
	open(OUT,">/data/accounts/user-") or die "FAILED";
	while(<IN>){
		if(m!</Users>!){
			while(my($key,$val)=each(%$user)){
				foreach my $j(@$val){
					my $user = $j;
					$user =~ s/@.+//;
					print OUT "\t<User id=\"$user\">\n";
					print OUT "\t\t<EmailAddress>$j</EmailAddress>\n";
					print OUT "\t\t<Group id=\"$key\" />\n";
					print OUT "\t</User>\n";
				}
			}
			print OUT;
		}else{
			print OUT;
		}
	}
	close(OUT);
	close(IN);
	system("/bin/mv /data/accounts/user- /data/accounts/user");
}

sub getprivilege(){
	my $group = shift;
	my @result;

	open(IN,"/data/accounts/group") or die "FAILED!!";
	while(<IN>){
		chomp;
		if(m!<Group id="$group">!){
			my $line = readline(IN);
			$line =~ m!<Ldap id="([^"]+)" confidential="(.)" login="(.)" />!;
			@result = ($1,$2,$3);
		}
	}
	if(@result < 3 ){
		return 1;
	}
	close(IN);

return @result;
}

sub duplicateCheck(){
	my $hash = shift;
	my @user = ();

	while(my($group, $array)=each(%$hash)){
		foreach my $user(@$array){
			push(@user,$user);
		}
	}
	my @array = grep {$count{$_}++} @user;
	if($#array < 0){
		return 1;
	}else{
		return 0;
	}

return 0;
}
close(DEBUG);

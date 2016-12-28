#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use auth;
use func qw(validity);
use JSON;
use env;

open(DEBUG,">/tmp/debug.log");

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

print "Content-type: application/json\n\n";
if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	my $ret;
	ldapDelete(@userList);
	groupDelete(@userList);
	$ret = &delete();
	_groupDelete(@userList);

	if($ret eq 0){
		$data->{'result'} = "SUCCESS";
		my $log = <<EOF;
$ENV{'REQUEST_URI'}
These IDs were deleted by $user.
@userList
EOF
		$audit->log($user,$log);
	}else{
		$data->{'result'} = "FAILED";
	}

}

print $json->encode($data);

sub delete(){
	my $ret;
	if($#userList gt -1){
		open(OUT,"|$base_dir/exp/deleteSSLAccount.exp $ipcom 'nt\%$env::region_num'");
		userDelete(OUT,@userList);
		close(OUT);
		$ret = 0;
		foreach my $operator(@userList){
			open(SMTP,"|$base_dir/pl/smtp.pl -f GCP_administrator\@jp.fujitsu.com -t $operator -b c3s-global-suppport-2nd\@ml.css.fujitsu.com -s 'SSL-VPN account deletion'> /dev/null");
			print SMTP "Your accounts for SSL-VPN and LDAP have been deleted by $user.";
			close(SMTP);
		}
	}else{
		$ret = 1;
	}

return $ret
}

sub userDelete($@){
	my $fhandle = shift;
	my @val = @_;
	foreach my $user(@val){
		print $fhandle "$user\n";
	}

return 0;
}

sub ldapDelete(@){
	@user = @_;
	foreach my $j(@user){
		open(LDAP,"|$base_dir/exp/deleteLDAPAccount.exp 2>/dev/null") or die "FAILED";
		print LDAP "$j\n";
		close(LDAP);
	}

return 0;
}

sub _groupDelete(){
	my @user = @_;
	my $list = ();
	open(IN,"/data/accounts/user") or die "FAILED";
	open(OUT,">/data/accounts/user-") or die "FAILED";
	my $i = 0;
	while(<IN>){
		if(/<User id="([^"]+)">/){
			$list->[$i]->[0] = $1
		}elsif(m!<EmailAddress>(.+)</EmailAddress>!){
			$list->[$i]->[1] = $1
		}elsif(m!<Group id="([^"]+)" />!){
			$list->[$i]->[2] = $1
		}elsif(m!<Privilege>(.+)</Privilege>!){
			push(@{$list->[$i]->[3]},$1);
		}elsif(m!</User>!){
			$i++;
		}
	}

	print OUT <<EOF;
<?xml version="1.0" encoding="utf-8"?>
<Users>
EOF
	foreach my $j(@{$list}){
		if(!grep(/^$j->[1]$/,@user)){
			print OUT "\t<User id=\"$j->[0]\">\n";
			print OUT "\t\t<EmailAddress>$j->[1]</EmailAddress>\n";
			print OUT "\t\t<Group id=\"$j->[2]\" />\n";
			if($j->[3] ne ""){
				foreach my $l(@{$j->[3]}){
					print OUT "\t\t<Privilege>$l</Privilege>\n";
				}
			}
			print OUT "\t</User>\n";
		}
	}
	print OUT "</Users>\n";
	close(OUT);
	close(IN);
	system("/bin/mv /data/accounts/user- /data/accounts/user");
}

sub groupDelete(@){
	@user = @_;
	foreach my $j(@user){
		my $user = $j;
		$user =~ s/@.*//;
		system("/bin/sed -i 's/:$user//g' /usr/local/2nd_tools/lib/group 2>/tmp/error");
	}
}
close(DEBUG);

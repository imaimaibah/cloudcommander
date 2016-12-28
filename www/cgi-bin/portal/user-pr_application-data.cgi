#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use env;
use func qw(web_cgi);
my $cgi = new web_cgi;
my $base_dir = $env::base_dir;
print "Content-type: text/plain\n\n";
#if($ENV{'REQUEST_METHOD'} eq "GET"){
if(1){
	my $Get = $ENV{'QUERY_STRING'};
	$cgi->hash($Get);
#### DELETE ####
	$cgi->{'file'} = "current";
	$cgi->{'lang'} = "en";
################
	if(! -e "/data/local_contents/user-pr/$cgi->{'lang'}/application-data.xml-$cgi->{'file'}"){
		getFile($cgi->{'lang'},"/data/local_contents/user-pr/$cgi->{'lang'}/application-data.xml-$cgi->{'file'}");
	}
	open(IN,"/data/local_contents/user-pr/en/application-data.xml-$cgi->{'file'}") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/<pledges>/){
			print; 
			print "\n";
			last;
		}
	}

	while(<IN>){
		chomp;
		s/\r//g;
		if(/<\/pledges>/){
			print;
			print "\n";
			last;
		}else{
			print;
			print "\n";
		}
	}
	close(IN);
}else{
	env::time_renew();
	my $backup = "/data/local_contents/user-pr/en/application-data.xml-$env::today$env::now";
	system("/bin/mv /data/local_contents/user-pr/en/application-data.xml-current $backup");
	open(OUT, ">/data/local_contents/user-pr/en/application-data.xml-current");
	open(IN,"$backup");
	while(<IN>){
		chomp;
		s/\r//g;
		print OUT;
		print OUT "\n";
		if(/<pledges>/){
			last;
		}
	}

	while(<SDTIN>){
		chomp;
		s/\r//g;
		print OUT;
		print OUT "\n";
	}

	while(<IN>){
		chomp;
		s/\r//g;
		if(/<\/pledges>/){
			print OUT;
			print OUT "\n";
			while(<IN>){
				chomp;
				s/\r//g;
				print OUT;
				print OUT "\n";
			}
		}
	}
	
	close(IN);
	close(OUT);
	system("/usr/local/2nd_tools/exp/scp.exp user-pr 'sv\@01011' '/data/local_contents/user-pr/en/application-data.xml-current' '/var/opt/FJSVj2ee/deployment/ijserver/myportal/apps/myportal.war/data/en_US/application-data.xml'");
}
close(DEBUG);

sub getFile($$){
	my $lang = shift;
	my $path = shift;
	if($lang eq "en"){
		$lang = "en_US";
	}

	system("$base_dir/exp/getFile.exp user-pr sv\@01011 '/var/opt/FJSVj2ee/deployment/ijserver/myportal/apps/myportal.war/data/$lang/application-data.xml' > $path");
}

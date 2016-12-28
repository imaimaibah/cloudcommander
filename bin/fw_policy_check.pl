#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;
my $from = 'shin.imai@jp.fujitsu.com';
my $to = 'root@mail-secure.sec.tatebayashi.sop';
my $subject = "$env::year/$env::mon/$env::mday FW POLICY $env::region";

fw_black();
fw_white();
create_mail("$base_dir/tmp/blacklist.csv", "$base_dir/tmp/whitelist.csv");

sub create_mail(){
	my $black = shift;
	my $white = shift;
	open(OUT,">$base_dir/tmp/fw_policy_check.mail") or die "FAILED!!";
	print OUT <<EOF;

FW rules for today

This e-mail is for notification purposes only. Please do not respond to
this email as this email address is not monitored.

EOF
	close(OUT);
	system("$base_dir/pl/smtp.pl -t '$to' -f '$from' -s '$subject' -d '$base_dir/tmp/fw_policy_check.mail' -a '$black' -a '$white'");
}

sub fw_black(){
	if(!-r "$base_dir/data/fw_blackList.sql"){
		print "Black List cannot be found\n";
		exit 1;
	}
	open(IN, "$base_dir/exp/fw_policy_check.exp black|") or die "FAILED!!";
	open(OUT, ">$base_dir/tmp/blacklist.csv") or die "FAILED!!";
	print OUT "Group ID,VSYS ID,FW ID,ACTION\n";
	while(<IN>){
		chomp;
		if(/[0-9a-zA-Z]{8}-[0-9a-zA-Z]{9}/){
			my @tmp = /[^|\s\t]+/g;
			foreach my $element(@tmp){
				print OUT $element.',';
			}
			print OUT "\n";
		}elsif(/Option is not specified/){
			print;
			print "\n";
			exit 1;
		}
	}
	close(OUT);
	close(IN);

return 0;
}

sub fw_white(){
	if(!-r "$base_dir/data/fw_whiteList.sql"){
		print "White List cannot be found\n";
		exit 1;
	}
	open(IN, "$base_dir/exp/fw_policy_check.exp white|") or die "FAILED!!";
	open(OUT, ">$base_dir/tmp/whitelist.csv") or die "FAILED!!";
	print OUT "Group ID,VSYS ID,FW ID,ACTION\n";
	while(<IN>){
		chomp;
		if(/[0-9a-zA-Z]{8}-[0-9a-zA-Z]{9}/){
			my @tmp = /[^|\s\t]+/g;
			foreach my $element(@tmp){
				print OUT $element.',';
			}
			print OUT "\n";
		}elsif(/Option is not specified/){
			print;
			print "\n";
			exit 1;
		}
	}
	close(OUT);
	close(IN);

return 0;
}

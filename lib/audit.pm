#!/usr/bin/perl -I/usr/local/2nd_tools/lib

package audit;
use env;
my $base_dir = $env::base_dir;
sub new(){
	my $pkg=shift;
	my $user = `id -un`;
	chomp($user);
	bless{
		user => $user,
	},$pkg;
}

sub audit($){
	my $self = shift;
	my $user = $self->{'user'};
	my $msg = shift;
	my $time = `date '+%Y/%m/%d %H:%M:%S'`;
	chomp($time);
	open(OUT,">>$base_dir/log/audit/$user");
		print OUT "$user $time $msg\n";
	close(OUT);

return 0;
}

sub send_mail($$$){
	my $self = shift;
	my $user = $self->{'user'};
	my $to = shift;
	my $cc = shift;
	my $msg = shift;
	open(OUT,"|$base_dir/pl/smtp.pl -f 'GCP_Administrator\@jp.fujitsu.com' -t '$to' -b '$cc'") or die "FAILED!!";
	print OUT $msg;
	close(OUT);

return 0;
}

package audit_web;

sub new(){
	my $pkg = shift;
	bless{},$pkg;
}

sub log(){
	my $self = shift;
	my $user = shift;
	my $data = shift;
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime(time());
	$sec = sprintf("%02d", $sec);
	$min = sprintf("%02d", $min);
	$hour = sprintf("%02d", $hour);
	$mday = sprintf("%02d", $mday);
	$mon = sprintf("%02d",++$mon);
	$year += 1900;
	my $today = "$year-$mon-$mday";
	my $now = "$hour:$min:$sec";

	open(OUT, ">>/data/audit/trace_$year$mon$mday.log") or die "FAILED";
  flock(OUT, 2);
  seek(OUT, 0, 2);
	foreach my $line(split(/\n/,$data)){
		print OUT "[$today $now] [$user] $line\n";
	}
	close(OUT);

return 0;
}
;1;

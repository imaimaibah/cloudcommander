#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;
my $data = ();
my $disk = ();
my $raid = ();
my $hotspare = 0;
my %target;
my $func = shift;
my $target = shift;
$target{'jp-01-1-et0000-09-18'} = "10.1.5.3";

my $test = '/home/shin.imai/inputfile';

START: while(my($key,$val)=each(%target)){
#	open(IN,"$base_dir/exp/disk_all.exp $val|") or die "FAILED";
	open(IN,"$test/disk/disk_result_22-2.log") or die "FAILED";
	my $i=0;
	while(<IN>){
		chomp;
		s/\r//g;
		if(/CONNECTION FAILED/){
			close(IN);
			next START;
			last;
		}
		if(/^$/){
			next;
		}elsif(/Location\s+\[(.+)\]/){
			my $tmp = $1;
			$data->{$val}->[$i]->{'disk'} = $tmp;
		}elsif(/^\s+Status\s+\[(.+)\]/){
			my $tmp = $1;
			my($status) = $tmp;
			$data->{$val}->[$i]->{'status'} = $status;
		}elsif(/RAID Group\s+\[(.+)\]/){
			my $tmp = $1;
			my($raid_d) = $tmp =~ /[^\s:]+/g;
			$data->{$val}->[$i]->{'raid'} = $raid_d;
		}elsif(/Firmware Revision/){
			$i++;
		}
	}
	close(IN);
	
	foreach my $j(@{$data->{$val}}){
		my $raid = $j->{'raid'};
		my $d = $j->{'disk'};
		my $status = $j->{'status'};
		$disk->{$val}->{$raid}->{$d} = $status;
	}
	
	#open(IN,"$base_dir/exp/show_raid.exp $val|") or die "FAILED";
	open(IN,"$test/raid/raid_result_08.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = /[^\s\t]+/g;
		if($tmp[0] ne "RAID" and $tmp[0] ne "No."){
			if($tmp[4] eq "No"){
				$raid->{$val}->{$tmp[0]} = "$tmp[4] $tmp[5] $tmp[6]";
			}elsif($tmp[5] eq "Rebuild"){
				$raid->{$val}->{$tmp[0]} = "$tmp[4] $tmp[5]";
			}else{
				$raid->{$val}->{$tmp[0]} = $tmp[4];
			}
		}
	}
	close(IN);
}


if($func eq "func3"){
	func3($raid,$disk);
}else{
	func1($raid,$disk);
}


sub func1(){
	my $raid = shift;
	my $disk = shift;
	my $result = ();
	my $juyo = 0;
	my $sai_juyo = 0;

	while(my($eternus,$d)=each(%$disk)){
		while(my($key,$val1)=each(%$d)){
			while(my($key2,$val)=each(%$val1)){
				if($val =~ /(Broken|Failed Usable|Not Supported|Not Exist|Unknown)/){
					$juyo = 1;
				}
			}
		}
	}

	if($juyo eq 1){
		disk_kowareteru_yo($raid,$disk);
	}

return 0;
}

sub func3(){
	my $raid = shift;
	my $disk = shift;
	my $result = ();
	my $sai_juyo = 0;
	my $juyo = 0;


	while(my($key,$val)=each(%$raid)){
		while(my($key1,$val1)=each(%$val)){
			if($val1 eq "Exposed"){
				$juyo = 1;
			}elsif($val1 eq "No Disk Path"){
				$sai_juyo = 1
			}elsif($val1 eq "Broken"){
				$sai_juyo = 1; 
			}elsif($val1 eq "Unknown"){
				$juyo = 1;
			}
		}
	}

	if($sai_juyo eq 1){
		cho_yabai($raid,$disk);
	}elsif($juyo eq 1){
		yabai($raid,$disk);
	}

return 0;
}

sub cho_yabai($$){
	my $raid = shift;
	my $disk = shift;
	my $result = ();

	while(my($eternus,$val)=each(%$raid)){
		while(my($raidNum,$status)=each(%$val)){
			while(my($name,$ip)=each(%target)){
				if($ip eq $eternus){
					$host = $name;
				}
			}
			if($status =~ /^(Exposed|Unknown)$/){
				system("logger -p user.err '2nd_tools:[$host]:[$eternus]:ETERNUS RAID Group [$raidNum]is Exposed.'");
			}elsif($status =~ /^(No Disk Path|Broken)$/){
				system("logger -p user.err '2nd_tools:[$host]:[$eternus]:ETERNUS RAID Group [$raidNum]is Broken.'");
			}
	
		}
	}

	#open(SMTP,"|$base_dir/pl/smtp.pl");
#print SMTP <<SMTP;
#SMTP
#	close(SMTP);
return 0;
}

sub yabai($$){
	my $raid = shift;
	my $disk = shift;
	my $result = ();
	my $host;
	

	while(my($eternus,$val)=each(%$raid)){
		while(my($raidNum,$status)=each(%$val)){
			while(my($name,$ip)=each(%target)){
				if($ip eq $eternus){
					$host = $name;
				}
			}
			if($status =~ /^(Exposed|Unknown)$/){
				system("logger -p user.err '2nd_tools:[$host]:[$eternus]:ETERNUS RAID Group [$raidNum]is Exposed.'");
			}elsif($status =~ /^(No Disk Path|Broken)$/){
				system("logger -p user.err '2nd_tools:[$host]:[$eternus]:ETERNUS RAID Group [$raidNum]is Unknown.'");
			}
		}
	}

	#open(SMTP,"|$base_dir/pl/smtp.pl");
#print SMTP <<SMTP;
#SMTP
#	close(SMTP);

return 0;
}

sub disk_kowareteru_yo($$){
	my $raid = shift;
	my $disk = shift;
	my $old = ();
	my $same = ();
	my $file_old = "/tmp/disk_check_func1-old.log";
	my $file_new = "/tmp/disk_check_func1.log";

	open(OUT,">$file_new");
	while(my($key,$val)=each(%$disk)){
		while(my($key1,$val1)=each(%$val)){
			while(my($key2,$val2)=each(%$val1)){
				if($val2 =~ /(Spare|Available)/){
					print OUT "$key,$key2,$val2,OK\n";
				}else {
					print OUT "$key,$key2,$val2,NG\n";
				}
			}
		}
	}
	close(OUT);

	open(IN,"$file_old") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		$old->{$tmp[0]}->{$tmp[1]}->[0] = $tmp[2];
		$old->{$tmp[0]}->{$tmp[1]}->[1] = $tmp[3];
	}
	close(IN);

	open(IN,"$file_new") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		$new->{$tmp[0]}->{$tmp[1]}->[0] = $tmp[2];
		$new->{$tmp[0]}->{$tmp[1]}->[1] = $tmp[3];
	}
	close(IN);

	compare($new,$old);

	system("/bin/mv $file_new $file_old");

return 0;
}

sub collect_target(){
	@tmp = ();
	%tmp = ();
	my $host;
	my $ip;
	open(IN,"$base_dir/exp/node_list.exp all|");
		while(<IN>){
			chomp;
			s/\r//g;
			if(/et[0-9]{4}-[0-9]{2}-[0-9]{2}/){
				@tmp = split(/,/);
				$tmp[0] =~ s/"//g;
				$tmp[1] =~ s/"//g;
				if($tmp[0] =~ /et[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
					$tmp{$tmp[0]} = $tmp[1];
				}
			}
		}
	close(IN);

return %tmp;
}

sub compare($$){
	my $new = shift;
	my $old = shift;
	my $flag = 0;

	open(OUT,">/tmp/disk_check_result.csv") or die "FAILED";

	print OUT "COMPARISON\n";
	print OUT "host,ipaddress,location,status,OK/NG\n";

	while(my($key,$val)=each(%$new)){
		my $host;
		returnHost($key,\$host);
		while(my($key1,$val1)=each(%$val)){
			if($old->{$key}->{$key1}->[1] eq "NG" and $val1->[1] eq "NG"){
				$flag++;
				print OUT "$host,$key,$key1,$val1->[0],NG\n";
			}
		}
	}

	print OUT "\nNEW\n";
	while(my($key,$val)=each(%$new)){
		my $host;
		returnHost($key,\$host);
		while(my($key1,$val1)=each(%$val)){
			if($old->{$key}->{$key1}->[1] eq "OK" and $val1->[1] eq "NG"){
				$flag++;
				print OUT "$host,$key,$key1,$val1->[0],NG\n";
			}
		}
	}

	close(OUT);

	if($flag ne 0){
		action($flag);
	}

}

sub returnHost($){
	my $ip = shift;
	my $host = shift;

	while(my($key,$val)=each(%target)){
		if($val eq $ip){
			$$host = $key;
		}
	}

}

sub action(){
	my $num = shift;
	system("logger -p user.err '2nd_tools:$num ETERNUS HDDs are Broken'");
	open(SMTP,"|$base_dir/pl/smtp.pl -t 'm-tetsu\@jp.fujitsu.com,shin.imai\@jp.fujitsu.com' -s 'ETERNUS HDD Report $env::today' -f 'c3s-global\@jp.fujitsu.com' -a '/tmp/disk_check_result.csv'");
	print SMTP <<EOF;
Hello;
EOF
	close(SMTP);
}
	

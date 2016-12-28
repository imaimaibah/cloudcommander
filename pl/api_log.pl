#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;

my $base_dir = $env::base_dir;
my @files;

open(IN,"$base_dir/exp/apiLogCollection.exp|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	if(/^no updates$/){
		exit;
	}else{
		push(@files,$_);
	}
}
close(IN);

my $yesterday = `date --date 'yesterday' +'\%Y-\%m-\%d'`;
chomp($yesterday);

my $tmp = ();
foreach my $file(@files){

if($file eq "ABSTrace.log"){
	system("tar zxf /tmp/tmp/ABSTrace.log.tgz -C /tmp/");
}else{
	system("gunzip /tmp/$file");
}

$file =~ s/(\.tgz|\.gz)$//g;

open(IN,"/tmp/$file") or die "FAIL";
my $data = ();
my $log = ();
my $i;
while(<IN>){
	if(/([^\s]+) ([^,]+).*\[(TP-Processor[0-9]+)\] DEBUG OViSSAPIInvoker[\s\t]+- invoke:(.*)$/){
		$data->{$3}->{'date'} = $1;
		$data->{$3}->{'time'} = $2;
		$data->{$3}->{'invoke'} = $4;
	}elsif(/\[(TP-Processor[0-9]+)\] DEBUG OViSSAPIImpl[\s\t]+- 【userId】：(.*)$/){
			$data->{$1}->{'user'} = $2;
	}elsif(/\[(TP-Processor[0-9]+)\] DEBUG OViSSAPIImpl[\s\t]+- 【orgId】：(.*)$/){
		$data->{$1}->{'org'} = $2;
	}elsif(/\[(TP-Processor[0-9]+)\] DEBUG OViSSAPIInvoker[\s\t]+- return:$/){
		my $processor = $1;
		if($data->{$processor}->{'date'} eq $yesterday){
			$log->[$i]->[0] = $data->{$processor}->{'date'};
			($log->[$i]->[1]) = split(/:/,$data->{$processor}->{'time'}); 
			$log->[$i]->[2] = $data->{$processor}->{'invoke'}; 
			$log->[$i]->[3] = $data->{$processor}->{'user'}; 
			$log->[$i]->[4] = $data->{$processor}->{'org'}; 
			$i++;
		}
		undef($data->{$processor});
	}
}
close(IN);


	foreach my $j(sort { $a->[1] <=> $b->[1] } @$log){
			$tmp->{$j->[0]}->{$j->[1]}->{$j->[4]}->{$j->[3]}->{$j->[2]} += 1;
	}
unlink("/tmp/$file");
}

open(OUT,">>/data/logs/api-access/$yesterday") or die "FAILED";
while(my($date,$val)=each(%$tmp)){
	foreach my $j(sort { $a <=> $b } keys(%$val)){
		while(my($org,$val2)=each(%{$val->{$j}})){
			while(my($user,$val3)=each(%$val2)){
				while(my($invoke,$val4)=each(%$val3)){
					if($j ne ""){
						print OUT "$date,$j,$org,$user,$invoke,$val4\n";
					}
				}
			}
		}
	}
}
close(OUT);


=pud


my %daily;
foreach my $val(sort { $a cmp $b } keys(%$tmp)){
	if($val eq ""){
		next;
	}
	while(my($key1,$val1)=each(%{$tmp->{"$val"}})){
			while(my($key2,$val2)=each(%$val1)){
				$daily{$val} += $val2;
			}
	}
}

$result->{'xText'} = "API LOG";
$result->{'yText'} = "Requests";
$result->{'unit'} = "";
foreach my $key(sort {$a cmp $b} keys(%daily)){
	push(@{$result->{'category'}},"$key hour");
	push(@{$result->{'series'}->[0]->{'data'}},$daily{$key});
}

print $obj->encode($result);

=cut

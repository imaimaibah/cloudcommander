package billing;

sub new(){
	my $pkg = shift;
	my $hregion = shift;
	my $hl_table = "/data/cgi-bin/billing_system_honbandesu/tables/host_lead_$hregion.table";
	my @trans_table = glob("/data/cgi-bin/billing_system_honbandesu/tables/transfer_price_*.table");
	my $cur_table = "/data/cgi-bin/billing_system_honbandesu/tables/currency.table";
	my $hl = ();
	my $trans = ();
	my $cur = ();

###
#seq,region_prefix,region_code,region_name,currency,decimal,update_date
###
	open(IN,"$cur_table") or die "$!";
	my $line = readline(IN);
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		$cur->{$tmp[1]}->{'cur'} = $tmp[4];
		$cur->{$tmp[1]}->{'decimal'} = $tmp[5];
		$cur->{$tmp[1]}->{'other'} = $tmp[2];
		$cur->{$tmp[2]}->{'cur'} = $tmp[4];
		$cur->{$tmp[2]}->{'decimal'} = $tmp[5];
		$cur->{$tmp[2]}->{'other'} = $tmp[1];
	}
	close(IN);

	open(IN,"$hl_table") or die "$!";
	$line=readline(IN);
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		#if($tmp[4] eq 0){
			@{$hl->{$tmp[1]}} = ($tmp[3],$tmp[5]);
		#}
	}
	close(IN);

###
#seq,product_id,product_name,list_price,JP,AU,SG,US,GB,DE,update_date
###
	foreach my $trans_table(@trans_table){	
	open(IN,"$trans_table") or die "$!";
	$line = readline(IN);
	my @header = split(/,/,$line);
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		if($tmp[1] =~ /^$hregion-/){
			$trans->{$tmp[1]}->{'name'} = $tmp[2];
			$trans->{$tmp[1]}->{'list_price'} = $tmp[3];
			for(my $i=4;$i<@header;$i++){
				$trans->{$tmp[1]}->{$header[$i]} = $tmp[$i];
			}
		}
	}
	close(IN);
	}

	bless{
		'host' => $hregion,
		'hl_table' => $hl,
		'trans_table' => $trans,
		'currency' => $cur,
		'host_region' =>$hregion,
	},$pkg;

}

sub calc(){
	my $self = shift;
	my $host = $self->{'host'};
	my $org;
	my $proID;
	my $unit;
	my $month = sprintf("%d",$env::mon);
	$month = sprintf("%02d",--$month);

	open(IN,"/data/html/cgi-bin/billing_system_honbandesu/usedlog/2013$month/$host/usedlogdata_2013$month\_001.csv") or die "$!";
	readline(IN);
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		if($tmp[3] =~ /^[A-Z0-9]{8}$/){
			$org= $tmp[3];
			$proID = $tmp[4];
			$unit = $tmp[18];
		}
		$self->{'bill'}->{$org}->{$proID} += $unit;
	}
	close(IN);
}

sub invoice(){
	my $self = shift;

	while(my($org,$val)=each(%{$self->{'bill'}})){
		my $lead = $self->{'hl_table'}->{$org}->[0];
		if($lead eq ""){
			$self->error("Not found in the host-lead table : $org");
		}
		my $lprice_total = sprintf("%.6f",0);
		my $tprice_total = sprintf("%.6f",0);
		my $tcurrency = $self->{'currency'}->{$lead}->{'cur'};
		my $lcurrency = $self->{'currency'}->{$self->{'host'}}->{'cur'};
		if(! -d "/data/cgi-bin/billing_system_honbandesu/invoice/$lead"){
			mkdir "/data/cgi-bin/billing_system_honbandesu/invoice/$lead";
		}
		if($self->{'hl_table'}->{$org}->[1] eq 1){
			open(OUT, ">/data/cgi-bin/billing_system_honbandesu/invoice/$lead/$org.csv") or die "$!";
		}else{
			open(OUT, ">/data/cgi-bin/billing_system_honbandesu/invoice/$lead/$org-FoC.csv") or die "$!";
		}
		print OUT "HostRegion,Product ID,Unit,$lcurrency List Price(per unit),$lcurrency List Price,$tcurrency Transfer Price(per unit),$tcurrency Transfer Price\n";
		while(my($product,$unit)=each(%$val)){
			if($self->{'trans_table'}->{$product} eq ""){
				next;
			}
			
			my $tprice = sprintf("%.6f",$self->{'trans_table'}->{$product}->{$tcurrency});
			my $lprice = sprintf("%.6f",$self->{'trans_table'}->{$product}->{'list_price'});
			my $lprice_unit = sprintf("%.6f",$unit * $lprice);
			my $tprice_unit = sprintf("%.6f",$unit*$tprice);
			$tprice_total += sprintf("%.6f",$tprice_unit);
			$lprice_total += sprintf("%.6f",$lprice_unit);
			my $name = $self->{'trans_table'}->{$product}->{'name'};
			print OUT "$self->{'host_region'},$product,$unit,$lprice,$lprice_unit,$tprice,$tprice_unit\n";
		}
		print OUT "Total,-,-,$lprice_total,-,$tprice_total\n";
		close(OUT);
	}
close(DEBUG);

}

sub invoiceTotal(){
	my $self = shift;

	my @all_lead = glob("/data/cgi-bin/billing_system_honbandesu/invoice/*");
	foreach my $lead(@all_lead){
		my @region = split(/\//,$lead);
		my $region = $region[$#region];
		open(OUT,">$lead/Total.csv") or die "$!";
		print OUT "Product ID,Unit,$self->{'currency'}->{$region}->{'cur'} Transfer Price(per unit),$self->{'currency'}->{$region}->{'cur'} Transfer Price\n";
		my $totalPrice = ();
		foreach my $file(glob("$lead/*")){
			if($file =~ /-FoC\.csv/ or $file =~ /Total\.csv/ or $file =~ /TotalList\.csv/){
				next;
			}
			open(IN,$file) or die "$!";
			my $line = readline(IN);
			while(<IN>){
				chomp;
				s/\r//g;
				if(!/^Total/){
					my @tmp = split(/,/);
					$totalPrice->{$tmp[1]}->{'trans'} = $tmp[5];
					$totalPrice->{$tmp[1]}->{'trans_unit'} += sprintf("%.6f",$tmp[6]);
					$totalPrice->{$tmp[1]}->{'unit'} += $tmp[2];
				}
			}
			close(IN);

		}
		my $total;

		while(my($pro,$val)=each(%$totalPrice)){
			$total += sprintf("%.6f",$val->{'trans_unit'});
			$utotal += sprintf("%.6f",$val->{'unit'});
			print OUT "$pro,$val->{'unit'},$val->{'trans'},$val->{'trans_unit'}\n";
		}
		print OUT "Total,-,-,$total\n";
		close(OUT);
	}

}

sub invoiceHTML(){
	my $self = shift;
	my @all_lead = glob("/data/cgi-bin/billing_system_honbandesu/invoice/*");
	
	foreach my $lead(@all_lead){
	my @region = split(/\//,$lead);
	my $region = $region[$#region];
	my $currency = $self->{'currency'}->{$region}->{'cur'};
		my $eco = 0;
		my $eco_usage = 0;
		my $eco_trans = 0;
		my $std = 0;
		my $std_usage = 0;
		my $std_trans = 0;
		my $adv = 0;
		my $adv_usage = 0;
		my $adv_trans = 0;
		my $high = 0;
		my $high_usage = 0;
		my $high_trans = 0;
		my $whigh = 0;
		my $whigh_usage = 0;
		my $whigh_trans = 0;
		my $sd = 0;
		my $sd_usage = 0;
		my $sd_trans = 0;
		my $dk1 = 0;
		my $dk1_usage = 0;
		my $dk1_trans = 0;
		my $dk2 = 0;
		my $dk2_usage = 0;
		my $dk2_trans = 0;
		my $dk3 = 0;
		my $dk3_usage = 0;
		my $dk3_trans = 0;
		my $dk32 = 0;
		my $dk32_usage = 0;
		my $dk32_trans = 0;
		my $ip = 0;
		my $ip_usage = 0;
		my $ip_trans = 0;
		my $nw1 = 0;
		my $nw1_usage = 0;
		my $nw1_trans = 0;
		my $nw2 = 0;
		my $nw2_usage = 0;
		my $nw2_trans = 0;
		my $nw3 = 0;
		my $nw3_usage = 0;
		my $nw3_trans = 0;
		my $total;
		open(IN,"$lead/Total.csv") or die "$!";
		my $line=readline(IN);
		while(<IN>){
			chomp;
			s/\r//g;
			my @tmp = split(/,/);
			if($tmp[0] =~ /^Total/){
				$total1 = $tmp[3];
			}
			if($tmp[0] =~ /-VM-0001-0001/){
				$eco_usage += $tmp[1];
				$eco  += $tmp[3];
				$eco_trans = $tmp[2];
			}elsif($tmp[0] =~ /-VM-0001-0002/){
				$std_usage += $tmp[1];
				$std  += $tmp[3];
				$std_trans = $tmp[2];
			}elsif($tmp[0] =~ /-VM-0001-0003/){
				$adv_usage += $tmp[1];
				$adv  += $tmp[3];
				$adv_trans = $tmp[2];
			}elsif($tmp[0] =~ /-VM-0001-0004/){
				$high_usage += $tmp[1];
				$high  += $tmp[3];
				$high_trans = $tmp[2];
			}elsif($tmp[0] =~ /-VM-0001-0011/){
				$whigh_usage += $tmp[1];
				$whigh  += $tmp[3];
				$whigh_trans = $tmp[2];
			}elsif($tmp[0] =~ /-SD-0001-0001/){
				$sd_usage += $tmp[1];
				$sd  += $tmp[3];
				$sd_trans = $tmp[2];
			}elsif($tmp[0] =~ /-DK-0001-0001/){
				$dk1_usage += $tmp[1];
				$dk1  += $tmp[3];
				$dk1_trans = $tmp[2];
			}elsif($tmp[0] =~ /-DK-0002-0001/){
				$dk2_usage += $tmp[1];
				$dk2  += $tmp[3];
				$dk2_trans = $tmp[2];
			}elsif($tmp[0] =~ /-DK-0003-0001/){
				$dk3_usage += $tmp[1];
				$dk3  += $tmp[3];
				$dk3_trans = $tmp[2];
			}elsif($tmp[0] =~ /-DK-0003-0002/){
				$dk32_usage += $tmp[1];
				$dk32  += $tmp[3];
				$dk32_trans  = $tmp[2];
			}elsif($tmp[0] =~ /-IP-0001-0001/){
				$ip_usage += $tmp[1];
				$ip  += $tmp[3];
				$ip_trans  = $tmp[2];
			}elsif($tmp[0] =~ /-NW-0001-0001/){
				$nw1_usage += $tmp[1];
				$nw1  += $tmp[3];
				$nw1_trans = $tmp[2];
			}elsif($tmp[0] =~ /-NW-0002-0001/){
				$nw2_usage += $tmp[1];
				$nw2  += $tmp[3];
				$nw2_trans = $tmp[2];
			}elsif($tmp[0] =~ /-NW-0002-0011/){
				$nw3_usage += $tmp[1];
				$nw3  += $tmp[3];
				$nw3_trans = $tmp[2];
			}
		}
		close(IN);
my $vm_total = sprintf("%.2f",$eco + $std + $adv + $high + $whigh);
my $sd_total = sprintf("%.2f",$sd);
my $disk_total = sprintf("%.2f",$dk1 + $dk2 + $dk3 + $dk32);
my $network_total = sprintf("%.2f",$ip + $nw1 + $nw2 + $nw3);
my @l = split(/\//,$lead);
$i = $l[$#l];
my @pdfHensu = $self->hensu_Maker($i);
$total = sprintf("%.2f",$vm_total + $sd_total + $disk_total + $network_total);
$l = $pdfHensu[8];
$l =~ s/,//;
$gtotal = sprintf("%.2f",$total - $l);
$total =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
$gtotal =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
$vm_total =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
$sd_total =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
$disk_total =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
$network_total =~ s/\G((?:^[-+])?\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;

my $last_month = eval{`date -d 'last month' '+%m'`};
my $this_month = eval{`date -d 'this month' '+%m'`};
my $year = `date -d 'last month' '+%Y'`;
chomp($last_month);
chomp($this_month);
chomp($year);
my @last_month_eigo = &env::convertMonth($last_month);

my $currency = $self->{'currency'}->{$i}->{'cur'};
open(OUT,">/data/html/billing_system/$i.html") or die "$!";
print OUT <<"EOF";
<!DOCTYPE html>
<html>

<head>
	<title>RR($pdfHensu[0])_$env::mon$env::mday</title>
	<link rel="stylesheet" href="/css/billing.css" />
</head>
 
<body>

<table>

<tr>
	<td align="left">
	<img src="jpg/fujitsuLogo.png" alt="Smiley face" height="84" width="155"> 
	</td>
	<td align="right">
	<!--Insert date here-->
	$env::eigo_mon[0] $env::mday, $env::year
	<!-------------------->
	<br>
	RR No.: GCP-$pdfHensu[0]$year$this_month
	</td>
</tr>

<tr>
	<td>
		$pdfHensu[3]
	</td>
</tr>

<tr>
	<td><br><br>
	<b>SUBJECT : $pdfHensu[0] Reseller Service Usage Report</b>
	</td>
</tr>

<tr>
	<td><br>
		$pdfHensu[4]
	</td>
</tr>

<tr>
	<td><br>
	Period : 
	<!--Insert date here-->
	$last_month_eigo[0] 01, $year
	<!-------------------->
	 to 
	<!--Insert date here-->
	$last_month_eigo[0] $last_month_eigo[2], $year
	<!-------------------->
	</td>
</tr>

<tr>
	<td><br>
	<b>Total amount of Usage</b>
	</td>
	<td align="right">
	<b><u>$currency</u>	<u>$gtotal</u></b>
	</td>
</tr>

<tr>
	<td><br><br>
	Payment Terms;<br>
	$pdfHensu[5]
	</td>
</tr>

<tr>
	<td><br><br>
	Sincerely,<br><br>
	$pdfHensu[6]
	</td>
</tr>

<tr>
	<td><br><br><br>
	$pdfHensu[7]
	</td>
</tr>

</table>

<table class='break'>

<tr>
	<td align="left">
	<img src="jpg/Logo.png" alt="Smiley face" height="84" width="155"> 
	</td>
</tr>

<tr>
	<td>
	$pdfHensu[0] GCP Monthly Reseller Service Usage Report   (Period : 
<!-------------------------------------------------------------------------------->
	$last_month/01/$year
<!-------------------------------------------------------------------------------->
	 to 
<!-------------------------------------------------------------------------------->
	$last_month/$last_month_eigo[2]/$year
<!-------------------------------------------------------------------------------->
	 )
	</td>
</tr>

<tr>
	<td>
	<table>
		<tr>
			<td bgcolor="black"><font color="white">
			Part Number</font>
			</td>
			<td bgcolor="black"><font color="white">
			Q'ty</font>
			</td>
			<td bgcolor="black"><font color="white">
			Unit Price ($currency)</font>
			</td>
			<td bgcolor="black"><font color="white">
			Amount ($currency)</font>
			</td>
		</tr>
		<tr>
			<td bgcolor="grey">
			NSG6000G
			</td>
			<td bgcolor="grey">
			1
			</td>
			<td bgcolor="grey">
			$gtotal
			</td>
			<td bgcolor="grey">
			$gtotal
			</td>
		</tr>
	</table>

	</td>
</tr>

<tr>
	<td><br>
	<b>1. Virtual Machine Usage</b>
	</td>
</tr>

<tr>
	<table>
		<tr>
			<td>
			</td>
			<td class="border1">
			Unit Price<br>
			($currency)
			</td>
			<td class="border1">
			Usage
			</td>
			<td class="border1">
			Amount
			</td>
		</tr>

		<tr>
			<td class="border">
			Economy VM Service
			</td>
			<td class="border1">
			$eco_trans
			</td>
			<td class="border1">
			$eco_usage
			</td>
			<td class="border1">
			$eco
			</td>
		</tr>

		<tr>
			<td class="border">
			Standard VM Service
			</td>
			<td class="border1">
			$std_trans
			</td>
			<td class="border1">
			$std_usage
			</td>
			<td class="border1">
			$std
			</td>
		</tr>

		<tr>
			<td class="border">
			Advance VM Service
			</td>
			<td class="border1">
			$adv_trans
			</td>
			<td class="border1">
			$adv_usage
			</td>
			<td class="border1">
			$adv
			</td>
		</tr>

		<tr>
			<td class="border">
			High-Performance VM Service
			</td>
			<td class="border1">
			$high_trans
			</td>
			<td class="border1">
			$high_usage
			</td>
			<td class="border1">
			$high
			</td>
		</tr>

		<tr>
			<td class="border">
			Double High VM Service
			</td>
			<td class="border1">
			$whigh_trans
			</td>
			<td class="border1">
			$whigh_usage
			</td>
			<td class="border1">
			$whigh
			</td>
		</tr>

		<tr>
			<td class="border">
			Quad High VM Service
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
		</tr>

		<tr>
			<td class="border">
			Sub total(1)
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td class="border1">
			$vm_total
			</td>
		</tr>
	</table>
</tr>

<tr>
	<td><br>
	<b>2. Standard Disk Usage</b>
	</td>
</tr>

<tr>
	<table>
		<tr>
			<td>
			</td>
			<td class="border1">
			Unit Price<br>
			($currency)
			</td>
			<td class="border1">
			Usage
			</td>
			<td class="border1">
			Amount
			</td>
		</tr>

		<tr>
			<td class="border">
			System Disk Service
			</td>
			<td class="border1">
			$sd_trans
			</td>
			<td class="border1">
			$sd_usage
			</td>
			<td class="border1">
			$sd
			</td>
		</tr>

		<tr>
			<td class="border">
			Sub total(2)
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td class="border1">
			$sd_total
			</td>
		</tr>
	</table>
</tr>

<tr>
	<td><br>
	<b>3. Storage Options Usage</b>
	</td>
</tr>

<tr>
	<table>
		<tr>
			<td>
			</td>
			<td class="border1">
			Unit Price<br>
			($currency)
			</td>
			<td class="border1">
			Usage
			</td>
			<td class="border1">
			Amount
			</td>
		</tr>

		<tr>
			<td class="border">
			Disk Expansion Option Service
			</td>
			<td class="border1">
			$dk1_trans
			</td>
			<td class="border1">
			$dk1_usage
			</td>
			<td class="border1">
			$dk1
			</td>
		</tr>

		<tr>
			<td class="border">
			Template Backup Service
			</td>
			<td class="border1">
			$dk2_trans
			</td>
			<td class="border1">
			$dk2_usage
			</td>
			<td class="border1">
			$dk2
			</td>
		</tr>

		<tr>
			<td class="border">
			System Backup Service
			</td>
			<td class="border1">
			$dk3_trans
			</td>
			<td class="border1">
			$dk3_usage
			</td>
			<td class="border1">
			$dk3
			</td>
		</tr>

		<tr>
			<td class="border">
			Data Backup Service
			</td>
			<td class="border1">
			$dk32_trans
			</td>
			<td class="border1">
			$dk32_usage
			</td>
			<td class="border1">
			$dk32
			</td>
		</tr>

		<tr>
			<td class="border">
			Sub total(3)
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td class="border1">
			$disk_total
			</td>
		</tr>
	</table>
</tr>

<tr>
	<td><br>
	<b>4. Network Options Usage</b>
	</td>
</tr>

<tr>
	<table>
		<tr>
			<td>
			</td>
			<td class="border1">
			Unit Price<br>
			($currency)
			</td>
			<td class="border1">
			Usage
			</td>
			<td class="border1">
			Amount
			</td>
		</tr>

		<tr>
			<td class="border">
			Global IP Address Attachment Service
			</td>
			<td class="border1">
			$ip_trans
			</td>
			<td class="border1">
			$ip_usage
			</td>
			<td class="border1">
			$ip
			</td>
		</tr>

		<tr>
			<td class="border">
			Internet Communication Service
			</td>
			<td class="border1">
			$nw1_trans
			</td>
			<td class="border1">
			$nw1_usage
			</td>
			<td class="border1">
			$nw1
			</td>
		</tr>

		<tr>
			<td class="border">
			Server Load-Balancing Service
			</td>
			<td class="border1">
			$nw2_trans
			</td>
			<td class="border1">
			$nw2_usage
			</td>
			<td class="border1">
			$nw2
			</td>
		</tr>

		<tr>
			<td class="border">
			Server Load-Balancing Service(Turbo)
			</td>
			<td class="border1">
			$nw3_trans
			</td>
			<td class="border1">
			$nw3_usage
			</td>
			<td class="border1">
			$nw3
			</td>
		</tr>

		<tr>
			<td class="border">
			Sub total(4)
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td bgcolor="grey" class="border1">
			</td>
			<td class="border1">
			$network_total
			</td>
		</tr>
	</table>

<table>
		<tr>
			<td>
				<br><b>Summary:</b><br>
			</td>
		</tr>
		<tr>
			<td>
			<table>
				<tr>
					<td></td>
					<td class="border3">Amount<br>($currency)</td>
				</tr>
				<tr>
					<td class="border2">Service Usage Total (1) + (2) + (3) + (4)</td>
					<td class="border3">$total</td>
				</tr>
				<tr>
					<td class="border2">Less: BES Cost</td>
					<td class="border3">$pdfHensu[8]</td>
				</tr>
				<tr>
					<td class="border2">Grand Total</td>
					<td class="border3">$gtotal</td>
				</tr>
			</table>
			</td>
		</tr>
	</table>
</tr>

</table>

</body>
 
</html> 

EOF
close(OUT);
}

}

sub gachanco(){
	my $self = shift;
	my @all_lead = glob("/data/cgi-bin/billing_system_honbandesu/invoice/*");

	foreach my $lead(@all_lead){
		open(OUT,">$lead/TotalList.csv") or die "$!";
		my @region = split(/\//,$lead);
		my $region = $region[$#region];
		print OUT "ContractID,HostRegion,Product ID,Unit,$self->{'currency'}->{$region}->{'cur'} List Price(per unit),$self->{'currency'}->{$region}->{'cur'} List Price,$self->{'currency'}->{$region}->{'cur'} Transfer Price(per unit),$self->{'currency'}->{$region}->{'cur'} Transfer Price\n";
		foreach my $file(glob("$lead/*")){
			if($file =~ /-FoC\.csv/ or $file =~ /Total\.csv$/ or $file =~ /TotalList\.csv$/){
				next;
			}
			my ($org) = $file =~ /([^\/]+)\.csv$/;
			open(IN,$file) or die "$!";
			my $line = readline(IN);
			my @tmp = ();
			my $total = 0;
			my $ltotal = 0;
			while(<IN>){
				chomp;
				s/\r//g;
				if(!/^Total/){
					print OUT "$org,";
					print OUT "$_\n";
					@tmp = split(/,/);
					$ltotal += $tmp[4];
					$total += $tmp[6];
		
				}
			}
			close(IN);
			print OUT "$org,-,Total,-,-,$ltotal,-,$total\n";
		}

		print OUT "\nFoC ContractIDs\n";

		foreach my $file(glob("$lead/*")){
			if($file !~ /-FoC\.csv/ or $file =~ /Total\.csv$/ or $file =~ /TotalList\.csv$/){
				next;
			}
			my ($org) = $file =~ /([^\/]+)-FoC\.csv$/;
			open(IN,$file) or die "$!";
			my $line = readline(IN);
			while(<IN>){
				chomp;
				s/\r//g;
				if(!/^Total/){
					print OUT "$org,";
					print OUT "$_\n";
				}
			}
			close(IN);
		}
		close(OUT);
	}
}

sub FoC(){
	my $self = shift;
	my %cpu = ();
	my $data = ();

	my $num = $env::year . sprintf("%02d",$env::mon - 1);

	foreach my $file(glob("/data/cgi-bin/billing_system_honbandesu/usedlog/$num/*/*")){
		open(IN,$file) or die $!;
		readline(IN);
		while(<IN>){
			chomp;
			s/\r//g;
			my $cpuNum=0;
			my @tmp = split(/,/);
			if($tmp[4] =~ /VM-0001-0001$/){
				$cpuNum=1;
			}elsif($tmp[4] =~ /VM-0001-0002$/){
				$cpuNum=2;
			}elsif($tmp[4] =~ /VM-0001-0003$/){
				$cpuNum=4;
			}elsif($tmp[4] =~ /VM-0001-0004$/){
				$cpuNum=8;
			}elsif($tmp[4] =~ /VM-0001-0011$/){
				$cpuNum=16;
			}elsif($tmp[4] =~ /VM-0001-0012$/){
				$cpuNum=32;
			}

			$cpu{$tmp[3]} += $cpuNum;
		}
		close(IN);
	}

	foreach my $file(glob("/data/cgi-bin/billing_system_honbandesu/tables/host_lead_*.table")){
		open(IN,$file) or die $!;
		readline(IN);
		while(<IN>){
			chomp;
			s/\r//g;
			my @tmp = split(/,/);
			if($tmp[5] eq '0'){
				$data->{$self->{'currency'}->{$tmp[3]}->{'other'}} += $cpu{$tmp[1]};
			}
		}
		close(IN);
	}

while(my($key,$val)=each(%$data)){
	print $key." - ".$val."\n";
}

}

sub checkFoC($){
	my $self = shift;
	my $org = shift;

}

sub error(){
	my $self = shift;
	my $msg = shift;

	#open(SMTP,"|$env::base_dir/pl/smtp.pl -f administrator\@jp.example.com -t support\@ml.css.example.com -s 'Billing Calculation' > /dev/null");
	#print SMTP "I found an error. Please see below\n\n";
	#print SMTP "$msg\n";
	#close(SMTP);
	die $msg;
}

sub hensu_Maker(){
	my $self = shift;
	my $lead = shift;
	if($lead eq ""){
		print "lead is empty";
		exit;
	}
	my @pdfHensu;

	$pdfHensu[1] = $env::mon.$env::mday;
	if($lead eq "JP01" or $lead eq "JP02"){
		$pdfHensu[0] = "Japan";
	}elsif($lead eq "AU01"){
		$pdfHensu[0] = "FAL";
		$pdfHensu[2] = "FUJITSU AUSTRALIA LIMITED";
		$pdfHensu[8] = "1,775";
		$pdfHensu[9] = "Darren Stafford";
		$pdfHensu[3] = <<EOF;
		$pdfHensu[2]<br>
		Sales & Services Delivery NSW<br>
		Mr. Darren Stafford<br>
EOF

		$pdfHensu[4] = <<EOF;
		Dear Mr. Darren Stafford<br><br>
		As per the Reseller Agreement between Fujitsu Limited and region, we are sending you the attached <br>
		Reseller Service Usage Report for the following period.<br>
EOF

		$pdfHensu[5] = <<EOF;
		FUJITSU LIMITED shall send an invoice to $pdfHensu[2].<br>
		$pdfHensu[2] shall pay to FUJITSU LIMITED the amount of<br>
		the reseller service usage described in the invoice on or before the last day of the month<br>
		following the month in which $pdfHensu[2] receives <br>
		the respective invoice.<br>

EOF

		$pdfHensu[6] = <<EOF;
		Ivy Francisco<br>
		GLOBAL SERVICE MANAGEMENT CENTER<br>
		FUJITSU LIMITED<br>
EOF

		$pdfHensu[7] = <<EOF;
Please confirm acceptance of this Reseller Service Usage Report by signing below.<br><br><br>
<table><tr><td width='100px' align='right'>Accepted by:</td><td class='l' width=300em>$pdfHensu[9]</td></tr><tr><td></td><td>$pdfHensu[2]</td></tr></table>
<table><tr><td width='100px' align='right'>Signature:</td><td class='l' width=300em></td></tr></table>
<br><br><br>
EOF
	}elsif($lead eq "SG01"){
		$pdfHensu[0] = "FAPL";
		$pdfHensu[2] = "FUJITSU ASIA PTE. LTD";
		$pdfHensu[8] = '1,611';
		$pdfHensu[9] = "Alex Leong Tze Jye";
		$pdfHensu[3] = <<EOF;
		$pdfHensu[2]<br>
		MS 113102-Cloud Computing-SOP<br>
		Mr. Alex Leong Tze Jye<br>
EOF

		$pdfHensu[4] = <<EOF;
		Dear Mr. Alex Leong Tze Jye<br><br>
		As per the Reseller Agreement between Fujitsu Limited and region, we are sending you the attached <br>
		Reseller Service Usage Report for the following period.<br>
EOF

		$pdfHensu[5] = <<EOF;
		FUJITSU LIMITED shall send an invoice to $pdfHensu[2].<br>
		$pdfHensu[2] shall pay to FUJITSU LIMITED the amount of<br>
		the reseller service usage described in the invoice on or before the last day of the month<br>
		following the month in which $pdfHensu[2] receives <br>
		the respective invoice.<br>

EOF

		$pdfHensu[6] = <<EOF;
		Ivy Francisco<br>
		GLOBAL SERVICE MANAGEMENT CENTER<br>
		FUJITSU LIMITED<br>
EOF

		$pdfHensu[7] = <<EOF;
Please confirm acceptance of this Reseller Service Usage Report by signing below.<br><br><br>
<table><tr><td width='100px' align='right'>Accepted by:</td><td class='l' width=300em>$pdfHensu[9]</td></tr><tr><td></td><td>$pdfHensu[2]</td></tr></table>
<table><tr><td width='100px' align='right'>Signature:</td><td class='l' width=300em></td></tr></table>
<br><br><br>
EOF

	}elsif($lead eq "US01"){
		$pdfHensu[0] = "FAI";
		$pdfHensu[2] = "FUJITSU AMERICA, INC.";
		$pdfHensu[8] = '1,563';
		$pdfHensu[9] = "Dennis Shuman";
		$pdfHensu[3] = <<EOF;
		$pdfHensu[2]<br>
		ITS Account Management<br>
		Mr. Dennis Shuman<br>
EOF

		$pdfHensu[4] = <<EOF;
		Dear Mr. Dennis Shuman<br><br>
		As per the Reseller Agreement between Fujitsu Limited and region, we are sending you the attached <br>
		Reseller Service Usage Report for the following period.<br>
EOF

		$pdfHensu[5] = <<EOF;
		FUJITSU LIMITED shall send an invoice to $pdfHensu[2]<br>
		$pdfHensu[2] shall pay to FUJITSU LIMITED the amount of<br>
		the reseller service usage described in the invoice on or before the last day of the month<br>
		following the month in which $pdfHensu[2] receives <br>
		the respective invoice.<br>

EOF

		$pdfHensu[6] = <<EOF;
		Ivy Francisco<br>
		GLOBAL SERVICE MANAGEMENT CENTER<br>
		FUJITSU LIMITED<br>
EOF

		$pdfHensu[7] = <<EOF;
Please confirm acceptance of this Reseller Service Usage Report by signing below.<br><br><br>
<table><tr><td width='100px' align='right'>Accepted by:</td><td class='l' width=300em>$pdfHensu[9]</td></tr><tr><td></td><td>$pdfHensu[2]</td></tr></table>
<table><tr><td width='100px' align='right'>Signature:</td><td class='l' width=300em></td></tr></table>
<br><br><br>
EOF
	}elsif($lead eq "GB01"){
		$pdfHensu[0] = "FS";
		$pdfHensu[2] = "FUJITSU SERVICES";
		$pdfHensu[8] = '1,750';
		$pdfHensu[9] = "Steve Hall";
		$pdfHensu[3] = <<EOF;
		$pdfHensu[2]<br>
		Product Management<br>
		Mr. Steve Hall<br>
EOF

		$pdfHensu[4] = <<EOF;
		Dear Mr. Steve Hall<br><br>
		As per the Reseller Agreement between Fujitsu Limited and region, we are sending you the attached <br>
		Reseller Service Usage Report for the following period.<br>
EOF

		$pdfHensu[5] = <<EOF;
		FUJITSU LIMITED shall send an invoice to $pdfHensu[2]<br>
		$pdfHensu[2] shall pay to FUJITSU LIMITED the amount of<br>
		the reseller service usage described in the invoice on or before the last day of the month<br>
		following the month in which $pdfHensu[2] receives <br>
		the respective invoice.<br>

EOF

		$pdfHensu[6] = <<EOF;
		Ivy Francisco<br>
		GLOBAL SERVICE MANAGEMENT CENTER<br>
		FUJITSU LIMITED<br>
EOF

		$pdfHensu[7] = <<EOF;
Please confirm acceptance of this Reseller Service Usage Report by signing below.<br><br><br>
<table><tr><td width='100px' align='right'>Accepted by:</td><td class='l' width=300em>$pdfHensu[9]</td></tr><tr><td></td><td>$pdfHensu[2]</td></tr></table>
<table><tr><td width='100px' align='right'>Signature:</td><td class='l' width=300em></td></tr></table>
<br><br><br>
EOF
	}elsif($lead eq "DE01"){
		$pdfHensu[0] = "FTS";
		$pdfHensu[2] = "FUJITSU TECHNOLOGY SOLUTIONS GMBH";
		$pdfHensu[8] = '1,575';
		$pdfHensu[9] = "Joachim Lohmann";
		$pdfHensu[3] = <<EOF;
		$pdfHensu[2]<br>
		FTS SBG MIS DCSC Cloud Services<br>
		Mr. Joachim Lohmann<br>
EOF

		$pdfHensu[4] = <<EOF;
		Dear Mr. Joachim Lohmann<br><br>
		As per the Reseller Agreement between Fujitsu Limited and region, we are sending you the attached <br>
		Reseller Service Usage Report for the following period.<br>
EOF

		$pdfHensu[5] = <<EOF;
		FUJITSU LIMITED shall send an invoice to $pdfHensu[2]<br>
		$pdfHensu[2] shall pay to FUJITSU LIMITED the amount of<br>
		the reseller service usage described in the invoice on or before the last day of the month<br>
		following the month in which $pdfHensu[2] receives <br>
		the respective invoice.<br>

EOF

		$pdfHensu[6] = <<EOF;
		Ivy Francisco<br>
		GLOBAL SERVICE MANAGEMENT CENTER<br>
		FUJITSU LIMITED<br>
EOF

		$pdfHensu[7] = <<EOF;
Please confirm acceptance of this Reseller Service Usage Report by signing below.<br><br><br>
<table><tr><td width='100px' align='right'>Accepted by:</td><td class='l' width=350em>$pdfHensu[9]</td></tr><tr><td></td><td>$pdfHensu[2]</td></tr></table>
<table><tr><td width='100px' align='right'>Signature:</td><td class='l' width=350em></td></tr></table>
<br><br><br>
EOF
	}


return @pdfHensu;
}

;1;

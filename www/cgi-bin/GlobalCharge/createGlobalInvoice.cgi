#!/usr/bin/perl -I /usr/local/2nd_tools/lib

use env;

my $table = {};
my $product = {};

my @region = ("JP01");

foreach my $region(@region){
	currency($table);
}

foreach my $region(@region){
	main($region,$table,$product);
}

display($product,$table);

sub currency($){
	my $table = shift;

	open(IN,"currency.txt");
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/=/);
		$table->{$tmp[0]} = $tmp[1];
	}
	close(IN);
}


sub main($$){
	my $region = shift;
	my $table = shift;
	my $product = shift;
	my $num;

	open(IN,"./product_$region.txt") or die "Failed!!";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/<NumOfResult>([0-9]+)<\/NumOfResult>/){
			$num = $1;
		}elsif(/<CurrencyUnit>(.+)<\/CurrencyUnit>/){
			$currency = $1;
		}elsif(/<ProductCode>(.*)<\/ProductCode>/){
			$product_code = $1;
		}elsif(/<UnitPrice>(.*)<\/UnitPrice>/){
			$unit_price = $1;
		}elsif(/<\/Product>$/){
			@{$product->{$product_code}} = ("$currency","$unit_price");
		}
	}

}

sub display(){
	$product = shift;
	$table = shift;

	while(my($key,$val)=each(%$product)){
		my $convert = sprintf("%.2f",$val->[1]*$table->{$val->[0]}-0.005);
		print "$key,$val->[1],$convert\n";
	}
}

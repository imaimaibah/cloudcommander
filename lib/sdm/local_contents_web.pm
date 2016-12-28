#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;

package terms_web;
sub new(){
	my $pkg = shift;
	my $original = shift;
	my $file = shift;
	if($original eq ""){
		die "Original is not specified";
	}
	my @dir = ();
	bless{dir => \@dir,file => $file, ori => $original},$pkg;
}

sub getList(){
	my $self=shift;
	my $dir=$self->{'dir'};
	@$dir = glob("$self->{'file'}-*");
	@$dir = sort {$b cmp $a} @$dir;

return $dir;
}

sub showList(){
	my $self=shift;
	$self->getList();
	my @list= ();
	my @dir = @{$self->{'dir'}};
	for(my $i=0;$i<=$#dir;$i++){
		if($i == 0){
			#printf("%s - %s\n",$i,"Current");
			push(@list,"current");
		}else{
			my @temp = $dir[$i] =~ /(.*)-([0-9]{14})$/;
			my $date = $self->convert($temp[$#temp]);
			#printf("%s - %s\n",$i,$date);
			push(@list,$date);
		}
	}

return @list;
}

sub show(){
	my $self=shift;
	my $choice = shift;
	my @dir = @{$self->{'dir'}};
	if($choice eq ""){
		$self->showList();
	}else{
		system("cat $dir[$choice]");
	}

return 0;
}

sub edit(){
	my $self=shift;
	my $file = $self->{'file'};
	my $choice = shift;
	env::time_renew();
	system("cp -p $file-current $file-$env::today$env::now");
	system("vi $file-current");
	system("clear");

return 0;
}

sub paste(){
	my $self=shift;
	my $file = $self->{'file'};
	print "Paste the entire content below and input single '.' at the end\n";
	env::time_renew();
	system("mv $file-current $file-$env::today$env::now");
	open(OUT,">$file-current") or die "hahahaha";
	while(my $line=readline(STDIN)){
		chomp($line);
		if($line =~ /^\.$/){
			last;
		}else{
			print OUT "$line\n";
		}
	}
	close(OUT);

return 0;
}

sub transfer(){
	my $self=shift;
	my $server = shift;
	my $password = shift;
	my $choice = shift;
	my @dir = @{$self->{'dir'}};
	my $file = $self->{'file'};
	if($choice ne '0'){	
		env::time_renew();
		system("/bin/mv $file-current $file-$env::today$env::now");
		system("/bin/mv $dir[$choice] $file-current");
	}
	system("$base_dir/exp/scp.exp $server $password $file-current $self->{'ori'}");

return 0;
}

sub convert(){
	my $self = shift;
	my $date = shift;
	my ($year,$month,$day,$hour,$min,$sec) = $date =~ /([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/;
	my $figure = "$year/$month/$day $hour:$min:$sec";

return $figure;
}

;1;

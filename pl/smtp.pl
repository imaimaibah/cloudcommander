#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use	 Socket;
use env;

$server = 'mail-secure';
$num = 0;
while(0<@ARGV){
	if($ARGV[0] eq '-t'){
		shift;
		if($ARGV[0] =~ /\s|,/){
			my @tmp = split(/,|\s/,shift);
			foreach my $tmp(@tmp){
				push(@to,$tmp);
			}
		}else{
			push(@to, shift);
		}
	}elsif($ARGV[0] eq '-c'){
		shift;
		if($ARGV[0] =~ /\s|,/){
			my @tmp = split(/,|\s/,shift);
			foreach my $tmp(@tmp){
				push(@cc,$tmp);
			}
		}else{
			push(@cc, shift);
		}
	}elsif($ARGV[0] eq '-b'){
		shift;
		if($ARGV[0] =~ /\s|,/){
			my @tmp = split(/,|\s/,shift);
			foreach my $tmp(@tmp){
				push(@bcc,$tmp);
			}
		}else{
			push(@bcc, shift);
		}
	}elsif($ARGV[0] eq '-f'){
		shift;
		$from = shift || 'sop@jp.fujitsu.com';
		@from_name = split(/@/,$from);
	}elsif($ARGV[0] eq '-s'){
		shift;
		$subject = shift || 'SOP mail';
	}elsif($ARGV[0] eq '-d'){
		shift;
		$data = shift;
		if(!-r "$data"){
			die "File cannot be read.";
		}
	}elsif($ARGV[0] eq '-a'){
		shift;
		if(!-r $ARGV[0]){
			die "File does not exist!!";
		}
		push(@attach,shift);
	}elsif($ARGV[0] eq '-e'){
		shift;
		$enc_flag = 1;
	}else{
		die "Invalid option is specified";
	}
}


# ------------------------------------------------------- #
# Header & Data
# ------------------------------------------------------- #

$send_data = 'X-Mailer: SMTP SOP' . "\n";
$send_data .= 'MIME-Version: 1.0' . "\n";
if(@attach lt 0){
	$send_data .= 'Content-Type: text/plain; charset=utf-8' . "\n";
}else{
	$send_data .= 'Content-Type: multipart/mixed; boundary="------_SOP_SYSTEM_MAIL_"'."\n"
}
$send_data .= 'From: '. $from_name[0] . ' <'. $from .'>' . "\n";
if($from eq ""){
	die "From is not specified";
}
#$send_data .= 'To: '. $to . "\n";
if(@to eq 0){
	die "To is not specified";
}
$send_data .= 'To:';
foreach my $to(@to){
	my @tmp = split(/@/,$to);
	$send_data .= " $tmp[0] <$to>,\n";
}

if(@cc ne 0){
	$send_data .= 'Cc:';
	foreach my $cc(@cc){
		my @tmp = split(/@/,$cc);
		$send_data .= " $tmp[0] <$cc>,\n";
	}
}
#$send_data .= "\n";
$send_data .= 'Subject: ' . $subject . "\n";

# ------------------------------------------------------- #
# Create SOCKET
# ------------------------------------------------------- #

	$port = getservbyname('smtp','tcp');
	
	$struct = sockaddr_in($port,inet_aton($server)); 

	socket(SH, PF_INET, SOCK_STREAM, 0)
		|| die("Failed to create a socket. $!");
		
	# Connect
	connect(SH, $struct )
		|| die("Connect Failed $!"); 
	
	# No Buffering
	select(SH); $| = 1; select(STDOUT);
	
	$respons = <SH>;

	unless($respons =~ /^220/){
		close(SH); die("Connect Failed $!"); 
	}

# ------------------------------------------------------- #
# Send the Commands
# ------------------------------------------------------- #


	# Create Command
	$command = "HELO $server\n";
	print SH $command ;

	# Check the response
	$respons = <SH> ;
	&decode(\$respons) ;

	# Check the response
	unless($respons =~ /^250/){
		close(SH); die("HELO Command failed. $!"); 
	}


	# Mail Command
	$command = "MAIL FROM:$from\n";
	print SH $command ; 

	# Check the response
	$respons = <SH> ;
	&decode(\$respons) ;

	unless($respons =~ /^250/){
		print SH "RSET\n"; close(SH);
		die("Fail Mail command $!") ; 
	}


	# RCPT Command
	foreach my $to(@to){
		$command = "RCPT TO:$to\n";
		print SH $command ;
		$respons = <SH> ;
		&decode(\$respons) ;
	}

	foreach my $cc(@cc){
		$command = "RCPT TO:$cc\n";
		print SH $command ;
		$respons = <SH> ;
		&decode(\$respons) ;
	}

	foreach my $bcc(@bcc){
		$command = "RCPT TO:$bcc\n";
		print SH $command ;
		$respons = <SH> ;
		&decode(\$respons) ;
	}

	# Check the response
	unless($respons =~ /^25[0|1]/){
		print SH "RSET\n"; close(SH);
		die("Fail RCPT command $!") ; 
	}

	# Data Command
	$command = "DATA\n";
	print SH $command ;

	# Check the response
	$respons = <SH> ;
	&decode(\$respons) ;

	unless($respons =~ /^354/){
		print SH "RSET\n"; close(SH);
		die("Fail DATA command $!") ; 
	}


	# Send data
	$command = "$send_data\n";
	print SH $command;
	if(@attach ge 0){
		print SH <<EOF;

--------_SOP_SYSTEM_MAIL_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

EOF
	}
	if($data ne ""){
		open(IN,$data);
		while($command = readline(IN)){
			chomp($command);
			print SH "$command\n";
		}
		close(IN);
	}else{
		while( my $line=readline(STDIN)){
			chomp($line);
			if($line eq '.'){
				last;
			}
			print SH "$line\n";
		}
	}
	foreach my $attach(@attach){
#	if($attach ne ""){
		my @filename = split(/\//,$attach);
		print SH <<EOF;

--------_SOP_SYSTEM_MAIL_
Content-Type: application/octet-stream;
 name="$filename[$#filename]"
Content-Disposition: attachment;
 filename="$filename[$#filename]"
Content-Transfer-Encoding: base64

EOF
		if($enc_flag eq '1'){
			open(IN,"openssl smime -encrypt -binary -aes256 -in $attach -outform DER $env::base_dir/certs/cert.pem |base64|") or die "FAILED!!";
		}else{
			open(IN,"base64 $attach|") or die "FAILED!!";
		}
		while(<IN>){
			print SH;
		}
		close(IN);
	}
	

	print SH ".\n";

	# Check the response
	$respons = <SH> ;
	&decode(\$respons) ;

	unless($respons =~ /^250/){
print $respons."\n";
		print SH "RSET\n"; close(SH);
		die("Body, Header failed $!") ; 
	}


	# Quit
	$command = "QUIT\n";
	print SH $command ;

# -------- Disconnect -------- #

	close(SH); select(STDOUT);
	
	print "Your Mail has been sent successfully\n";

# --------------------
# Convert Line feed code
# --------------------
sub decode{
	
	my $inf = $_[0];
	$$inf =~ s/\x0D\x0A|\x0D|\x0A/\n/g;

}

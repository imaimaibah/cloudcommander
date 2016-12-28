#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use auth;
use JSON;
use func qw(web_cgi);

my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
#### DELETE BELOW LINES ####
$user = "shin.imai";
############################
my $auth = new auth($user);
my $cgi = new web_cgi;
my $obj =  new JSON();
my $data = "";
$cgi->hash($ENV{'QUERY_STRING'});

print "Content-type: text/html\n\n";
while(<>){
chomp;
s/\r//g;
$data = $_;
print $data;
}
open(OUT,">/data/html/tmp.html");
print OUT <<EOF;
<!DOCTYPE HTML>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>VM Status</title>
		<script type="text/javascript" src="/js/jquery-1.7.2.js"></script>
		<script type="text/javascript" src="/trend/scripts/query.js"></script>
		<script type="text/javascript" src="/js/main.js"></script>
		<script type="text/javascript" src="/js/trend.js"></script>
		<script type="text/javascript" src="/trend/scripts/highcharts.js"></script>
		<script type="text/javascript">
		sessionStorage.setItem("graph",'$data');
		var data = JSON.parse(sessionStorage.getItem("graph"));
for(var i in data.lserver){
	alert(i+"  "+data.lserver[i])
}
		drawLine(data.lserver,'graph','line')
		</script>
	</head>
<body>
<table width="100%" border=1>
	<tr>
	<td>
	<div id='graph'></div>
	</td>
	</tr>
</table>
</body>
</html>
EOF
close(OUT);
if($cgi->{'format'} eq "pdf"){
	createHTML();
	createPDF();
	print "Trend.pdf";
}elsif($cgi->{'format'} eq "jpg"){
	createHTML();
	print "Trend.jpg";
}else{
	createCSV();
	print "Trend.csv";
}


sub createHTML(){

return 0;
}

sub createCSV(){

return 0;
}

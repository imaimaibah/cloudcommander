#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#Version: 1.0

use env;

my $base_dir = $env::base_dir;
my $now = `date +%s`;
my $date = $now - 22200;
my $data = [];
my $i = 0;

# backuptime.expの実行
open(IN,"$base_dir/exp/backuptime.exp $date|") or die "FAILED";

# backuptime.expで取得したselect結果の分析
while(<IN>){
	chomp;
	s/\r//g;
  # 契約ID記載の行のみを抽出し不要な文字列を削除
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}/){
    my @tmp = split(/\|/);
    foreach my $l(@tmp){
            $l=~s/^\s+//;
            $l=~s/\s+$//;
    }
    push @$data, \@tmp;
    # バックアップ所要時間(min/GB)の算出→閾値との比較→該当すれば配列に格納
    my $backuptime = ($data->[$i][11] - $data->[$i][10])/$data->[$i][3]/1000/60;    
    if($backuptime >= 3.0){
      push @vm, $data->[$i][1];
    }
    $i++
  }
}
# メッセージ出力用に整形し、該当VMがあればloggerに出力
###
#@vm = "TEST";
###
my $mes = join(",",@vm);
if($mes eq ""){
   print "NO SUCH VM\n"; #perl単体実行時の出力用
}else{
   print ($_ ,"\n")foreach(@vm); #perl単体実行時の出力用
   system("logger -p 'user.err' 'ERROR_backuptime:It takes time more than assumption to disk back up. => @vm'");  
}

close(IN);

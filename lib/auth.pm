#!/usr/bin/perl -I/usr/local/2nd_tools/lib

package auth;

sub new(){
	my $pkg = shift;
	
	bless{
		user => shift,
	},$pkg;
}

sub auth(){
	my $self = shift;
	my @group = @_;

	open(IN,"/usr/local/2nd_tools/lib/group") or die "FAILED";
	while(<IN>){
		chomp;
		my @tmp = split(/:/);
		foreach my $group(@group){
			if($group eq $tmp[0]){
				shift(@tmp);
				foreach my $u(@tmp){
					if($u eq $self->{'user'}){
						return 1;
					}
				}
			}
		}
	}
	close(IN);

return 0;
}

sub _auth(){
use File::Basename;
	my $self = shift;
	my ($pkg, $file, $line) = caller;
	$file = basename($file);

	$self->findUser();
	$self->findGroup();

	foreach my $p(@{$self->{'privilege'}}){
		if($p eq $file){
			return 1;
		}
	}

return 0;
}

sub findUser(){
	my $self = shift;
	open(IN, "/data/accounts/user") or die "FAILED!!";
	while(<IN>){
		chomp;
		if(my($user) = /<User id="([^"]+)">/){
			if(lc($user) eq lc($self->{'user'})){
				while(my $line = readline(IN)){
					chomp($line);
					if($line =~ /<Group id="([^"]+)" \/>/){
						$self->{'group'} = $1;
					}elsif($line =~ m!<Privilege>(.+)</Privilege>!){
						push(@{$self->{'privilege'}},$1);
					}elsif($line =~ m!<EmailAddress>(.+)</EmailAddress>!){
						push(@{$self->{'email'}},$1);
					}elsif($line =~ m!</User>!){
						last;
					}
				}
			}
		}
	}
	close(IN);
}

sub findGroup(){
	my $self = shift;
	my $group = shift;
	if($group eq ""){
		$group = $self->{'group'};
	}
	open(IN, "/data/accounts/group") or die "FAILED!!";
	while(<IN>){
		chomp;
		if(/<Group id="$group">/){
			while(my $line = readline(IN)){
				chomp($line);
				if($line =~ m!<Ldap id="([^"]+)" confidential="(.)" />!){
					$self->{'ldap'}->{'group'} = $1;
					$self->{'ldap'}->{'confidential'} = $2;
				}elsif($line =~ m!<Privilege>(.+)</Privilege>!){
					push(@{$self->{'privilege'}},$1);
				}elsif($line =~ m!</Group>!){
					last;
				}
			}
		}
	}
	close(IN);

}

sub userList(){
	my $self = shift;
	my $i = 0;
	open(IN, "/data/accounts/user") or die "FAILED!!";
	while(<IN>){
		chomp;
		if(/<User id="([^"]+)">/){
			$self->{'users'}->[$i]->[0] = $1;
		}elsif(m!<EmailAddress>(.+)</EmailAddress>!){
			$self->{'users'}->[$i]->[1] = $1;
		}elsif(m!<Group id="([^"]+)" />!){
			$self->{'users'}->[$i]->[2] = $1;
		}elsif(m!</User>!){
			$i++;
		}
	}
	close(IN);

return 0;
}

sub groupList(){
	my $self = shift;
	open(IN,"/data/accounts/group") or die "FAILED!!";
	while(<IN>){
		chomp;
		if(/<Group id="([^"]+)"/){
			push(@{$self->{'groups'}},$1);
		}
	}
	close(IN);

return 0;
}

sub show(){
	my $self = shift;
	my $user = shift;
	$self->findUser();
	$self->findGroup();

return 0;
}

;1;

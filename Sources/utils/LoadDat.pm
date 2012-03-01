package LoadDat;
#TODO: faire mieux
#TODO: gérer les erreurs
#TODO: utiliser Glib::KeyFile
#TODO: gérer les fins de lignes windows sur linux
use strict;

# our $DEBUG = 1;
=head1 LoadDat
Lit un fichier au format suivant
[titre1]
c1\t c2\t c3
a1\t a2\t a3

#commentaire : commence par un #
[titre2]
d1\t d2\t d3
..

renvoie un tableau d'élements
@ = ( {titre => 'titre1', contenu=> [[c1, c2,c3], [a1,a2,a2]]} ..
=cut

# use base qw(ErreurMod);
use ErreurMod;
use utf8;
#renvoie undef si erreur
sub load{
	my $filename = shift;

  if (!open(FIC,"<:utf8",$filename)) {
    set_erreur("$!");
    return undef;
  }

  # print "$filename\n" if ($DEBUG);
	my @h = ();
  my $cur = {titre => '', contenu => []};
  push @h, $cur;

  while (my $line = <FIC>) {
    #enlève le caractère \n de la ligne
    chomp $line;
    next if $line =~ /^\s*$/ || $line =~ /^#/;

    if ($line =~ /\[(([\w '])*)\]/) {
      #print "[$1]\n";
      # print "$line\n" if ($DEBUG);
      $cur = {titre => $1, contenu => []};
      push @h,$cur;
    }
    else
    {
      # print "$line\n" if ($DEBUG);
      my @tabl = split(/\t/,$line);
      #print "$tabl[0]\n";
      push @{$cur->{contenu}}, \@tabl;
    }
  }


  close FIC;
  if (scalar(@{$h[0]->{contenu}}) == 0) {
	  shift @h;
	}
	return \@h;
}
# use Data::Dumper;
#renvoie false si erreur
sub save {
	my ($filename, $h) = @_;

  if (!open(FIC,">:utf8",$filename)) {
    set_erreur( "$!" );
    #return false
    return 0;
  }

  foreach my $section (@$h) {
		# print Dumper($section);
		my $titre = $section->{titre};
    print FIC "[$titre]\n";
    foreach my $terrine (@{$section->{contenu}}) {
      print FIC (join "\t", @{$terrine});
			print FIC "\n";
    }
  }

  close FIC;
	return 1;
}
1;

package file::Carburant;

use strict;

use LoadDat;

use models::BaseItem;
use models::ListeCarburant;

=pod
Charge la base de données de carburant, construit un tableau de {masse => , bras =>
=cut

#use constant COL_VOLUME => 0;
use constant COL_MASSE  => 0;
use constant COL_BRAS   => 1;

use constant SECTION_CARBURANT => 0;
use constant SECTION_NOURRICE => 1;

use utf8;
use ErreurMod;

sub load {
  my ($base_filename) = @_;
  my $base = LoadDat::load($base_filename);
  
  if (!$base) {
    set_erreur ("Impossible de charger les donnés carburant de $base_filename : ".LoadDat::get_erreur);
    return undef;
  }
  
  if ($#$base < 0) {
    set_erreur ("Impossible de charger les donnés carburant de $base_filename : ".LoadDat::get_erreur);
    return undef;
  }
  
  
  my @tab_carburant = ();
  
  foreach my $ligne (@{$base->[SECTION_CARBURANT]->{contenu}}) {
		push @tab_carburant,models::BaseItem->new($ligne->[COL_BRAS], $ligne->[COL_MASSE]);
  }

  
  my $limite_nourrice = undef;
  my $section = $base->[SECTION_NOURRICE];

  $limite_nourrice = $section->{contenu}->[0][0] if (defined ($section));

  return models::ListeCarburant->new(\@tab_carburant, $limite_nourrice); 

}

1;

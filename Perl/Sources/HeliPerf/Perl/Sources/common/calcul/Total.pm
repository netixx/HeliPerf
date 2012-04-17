package calcul::Total;

use strict;

use calcul::Centrage;
=pod
****CLASSE TotalItem*****

Classe utilisée par ListeMatos et GrapheCentrage
Représente les donnés de la ligne total (bras total, masse totale, iter correspondant au GtkTreeIter de la dernière ligne)

Le bras total est la moyenne des bras pondérée par les masses
=cut

use models::BaseItem;
use base qw(models::BaseItem);

sub new {
  my ($class, $bras, $masse) = @_;
  return bless(models::BaseItem->new($bras, $masse), $class);
}

=pod
_add_pondere($bras, $masse)
ajoute le bras $bras, pondéré par la masse $masse pour le calcul du bras et de la masse totale
=cut
# sub _add_pondere {
  # my ($this, $bras, $masse) = @_;  
  # my $massetot = $this->get_masse + $masse;
  # comme annoncé, le calcul barycentrique
  # $this->{_BRAS}  = ($this->get_bras * $this->get_masse + $bras * $masse) / $massetot;
  # $this->{_MASSE} = $massetot;
# }


=pod
Méthodes utilisés par ListeMatos exclusivement
=cut



#ajoute un item : calcul pondéré de la masse totale en conséquencec (seul le bras et la masse de l'item sont utilisés)
sub add_item {
  my ($this, $item) = @_;
  $this->set_bras_masse(calcul::Centrage::ajoute_masse($this->get_bras_masse, $item->get_bras_masse));
}

#enlève un item
sub remove_item {
  my ($this, $item) = @_;
  $this->set_bras_masse(calcul::Centrage::enleve_masse($this->get_bras_masse, $item->get_bras_masse));
}

#sub update_item {
	#my ($this, $old_bras, $old_masse, $item) = @_;
	#$this->set_bras_masse(calcul::Centrage::rafraichir_masse($this->get_bras_masse, $old_bras, $old_masse,
		#$item->get_bras_masse));
#}

1;

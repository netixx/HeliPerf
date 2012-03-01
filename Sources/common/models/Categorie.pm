package models::Categorie;

=pod
****CLASSE Categorie*****

Représente une catégorie de matériel (qui donnera lieu à un onglet)
=cut

use strict;

sub new {
  my ($class, $titre, $tabl) = @_;
  my $this = {_TITRE => $titre, _ITEMS => $tabl};
  return bless ($this, $class);
}

sub get_nom {
  return shift->{_TITRE};
}

#renvoie la liste des $items relevant de cette catégorie
sub get_items {
  return shift->{_ITEMS};
}

1;

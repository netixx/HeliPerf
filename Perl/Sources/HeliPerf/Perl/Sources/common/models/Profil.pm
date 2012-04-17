package models::Profil;

=pod
****CLASSE Profil*****

Représente un profil
=cut

use strict;

sub new {
  my ($class, $titre, $tabl) = @_;
  my $this = {_NOM => $titre, _IDS => $tabl};
  return bless ($this, $class);
}

sub get_nom {
  return shift->{_NOM};
}

sub set_nom {
	my ($this, $nom) = @_;
	$this->{_NOM} = $nom;
}

#renvoie la liste des $items relevant de cette catégorie
sub get_ids {
  return shift->{_IDS};
}

sub set_ids {
	my ($this, $ids) = @_;
	$this->{_IDS} = $ids;
}

1;

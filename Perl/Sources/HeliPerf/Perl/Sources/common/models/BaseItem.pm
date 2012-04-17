package models::BaseItem;

=pod
****CLASSE BaseItem*****
Classe de base 
Représente un objet ayant une masse et un bras
Cf Onglets et mainWin::widgets::ListeMatos pour la doc

BaseItem -> Item
=cut

use strict;

sub new {
  my ($class, $bras, $masse) = @_;
  my $this = { _MASSE => $masse, _BRAS => $bras};
  return bless ($this, $class);
}



sub get_bras {
  return shift->{_BRAS};
}


sub get_masse {
  return shift->{_MASSE};
}

sub get_bras_masse {
  my $this = shift;
  return ($this->{_BRAS}, $this->{_MASSE});
}

sub set_bras {
  my ($this, $bras) = @_;
  $this->{_BRAS} = $bras;
}

sub set_masse {
  my ($this, $masse) = @_;
  $this->{_MASSE} = $masse;
}

sub set_bras_masse {
  my ($this, $bras, $masse) = @_;
  $this->{_MASSE} = $masse;
  $this->{_BRAS} = $bras;
}


1;

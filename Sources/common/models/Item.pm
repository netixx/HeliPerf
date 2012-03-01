package models::Item;
#TODO: séparer en deux classes : l'une utilisé par mainWin et une abstraite


=pod
****CLASSE Item*****
Classe d'interface pour Onglets et mainWin::widgets::ListeMatos
Représente un matériel
Cf Onglets et mainWin::widgets::ListeMatos pour la doc
=cut

use strict;

#un item a une masse et un bras
use base qw(models::BaseItem);


sub new {
	my ($class, $bras, $masse, $nom, $bras_l, $img, $est_present_pesee, $dragable, $id) = @_;
	my $this = models::BaseItem->new($bras, $masse);
	$this->{_ID} = $id;
	$this->{_NOM} = $nom;
	$this->{_IMG} = $img;
	$this->{_BRAS_L} = $bras_l;
	$this->{_PRESENT_PESEE} = $est_present_pesee;
	$this->{_DRAGABLE} = $dragable;
		#_NOM => $nom,_BRAS_L => $bras_l, _IMG => $img};
	return bless ($this, $class);
}

sub set_id {
	my ($this, $id) = @_;
	$this->{_ID} = $id;
}

sub get_id {
	return shift->{_ID};
}

sub get_nom {
	return shift->{_NOM};
}

sub get_bras_l {
	return shift->{_BRAS_L};
}

sub get_img {
	return shift->{_IMG};
}

sub set_bras_l {
	my ($this, $bras_l) = @_;
	$this->{_BRAS_L} = $bras_l;
}

#Etait-ce présent lors de la pesée ?
sub is_present_pesee {
	return shift->{_PRESENT_PESEE};
}

sub is_dragable {
	return shift->{_DRAGABLE};
}

1;

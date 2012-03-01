package models::Helico;
#TODO: faire une classe de basse (pas besoin de on_Onglets_button_activate etc)

use strict;
use models::Item;


=pod
****CLASSE Helico*****
Représente un hélico

=cut

#Un hélico est un item
use base qw(models::Item);

sub new {
	my ($class, $bras, $masse, $nom, $bras_l, $img, $icone, $graphcoord,
		$schemaratiox,$schemaratioy,$schemaoffsetx,$schemaoffsety,
		$masse_pesee, $bras_pesee, $masse_vide, $bras_vide, $configbase) = @_;
	my $this = $class->SUPER::new($bras, $masse, $nom, $bras_l, $img);
	$this->{_GRAPHCOORD} = $graphcoord;
	$this->{_SCHEMARATIOX} = $schemaratiox;
	$this->{_SCHEMARATIOY} = $schemaratioy;
	$this->{_SCHEMAOFFSETPIXX} = $schemaoffsetx*$schemaratiox;
	$this->{_SCHEMAOFFSETPIXY} = $schemaoffsety*$schemaratioy;
	$this->{_ICONE} = $icone;
	$this->{_MASSE_P} = $masse_pesee;
	$this->{_BRAS_P} = $bras_pesee;
	$this->{_CONFIG} = $configbase;
	$this->{_MASSE_V} = $masse_vide;
	$this->{_BRAS_V} = $bras_vide;

	return bless ($this, $class);
}


sub get_masse_vide {
	return shift->{_MASSE_V};
}

sub get_bras_vide {
	return shift->{_BRAS_V};
}

#la masse sans la config de base
sub set_bras_masse_vide {
	my ($this, $bras, $masse) = @_;
	$this->{_MASSE_V} = $masse;
	$this->{_BRAS_V } = $bras;
}

sub get_bras_masse_vide {
	my $this = shift;
	return ($this->{_BRAS_V}, $this->{_MASSE_V});
}

sub get_bras_masse_pesee {
	my $this = shift;
	return ($this->{_BRAS_P}, $this->{_MASSE_P});
}

sub set_bras_masse_pesee {
	my ($this, $bras, $masse) = @_;
	$this->{_MASSE_P} = $masse;
	$this->{_BRAS_P } = $bras;
}

sub get_bras_pesee {
	return shift->{_BRAS_P};
}

sub get_masse_pesee {
	return shift->{_MASSE_P};
}

sub get_config_base {
	return shift->{_CONFIG};
}

sub set_config_base {
	my ($this, $config) = @_;
	$this->{_CONFIG} = $config;
}

sub get_limite_centrage_coords {
	return shift->{_GRAPHCOORD};
}

sub get_schemaratiox {
	return shift->{_SCHEMARATIOX};
}

sub get_schemaratioy {
	return shift->{_SCHEMARATIOY};
}

sub get_schemaoffsetpixx {
	return shift->{_SCHEMAOFFSETPIXX};
}
sub get_schemaoffsetpixy {
	return shift->{_SCHEMAOFFSETPIXY};
}
sub get_icone {
	return shift->{_ICONE};
}
1;

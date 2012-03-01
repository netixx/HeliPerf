package  models::MainItem;

use strict;

use models::Item;
use base qw(models::Item);
use calcul::Centrage;

sub new {
	my ($class, @arg) = @_;
	my $this = models::Item->new(@arg);
	$this->{_ITEMS} = [];
	return bless($this, $class);
}


sub add_item {
	my ($this, $item) = @_;
	# $this->set_bras_masse(calcul::Centrage::ajoute_masse($this->get_bras_masse, $item->get_bras_masse));
	push @{$this->{_ITEMS}}, $item;
}

sub get_items {
	return shift->{_ITEMS} ;
}

1;

package models::Carburant;

#TODO: vérifier le pas
sub new {
	my ($class, $aTableItems) = @_;
	my $pas = $aTableItems->[1]->get_masse - $aTableItems->[0]->get_masse;
	return bless({_ITEMS => $aTableItems, _PAS => $pas}, $class);
}

sub get_items {
	return shift->{_ITEMS};
}

sub get_pas {
# Pour obliger calcul::Carburant à tout recalculer (pb avec écureuil)
	return undef;
#  return shift->{_PAS};
}

sub maxmasse {
	my $items = shift->get_items;
	return $items->[$#$items]->get_masse;
}

1;

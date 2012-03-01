package models::ListeCarburant;

#TODO: vérifier le pas
sub new {
	my ($class, $aTableItems, $limite_nourrice) = @_;
	my $pas = $aTableItems->[1]->get_masse - $aTableItems->[0]->get_masse;
	return bless({_ITEMS => $aTableItems, _PAS => $pas, _LIMITE_NOURRICE => $limite_nourrice}, $class);
}

sub get_limite_nourrice {
	return shift->{_LIMITE_NOURRICE};
}

sub get_items {
	return shift->{_ITEMS};
}

sub get_pas {
	#pb avec écureuil : force calcul::Carburant à tout recalculer
	return undef;
	return shift->{_PAS};
}

sub maxmasse {
	my $items = shift->get_items;
	return $items->[$#$items]->get_masse;
}




1;

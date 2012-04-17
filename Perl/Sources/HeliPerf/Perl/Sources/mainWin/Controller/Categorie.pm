package mainWin::Controller::Categorie;

use mainWin::Controller::Item;

sub new {
	my ($class, $categorie) = @_;
	my $this = bless ({_NOM => $categorie->get_nom }, $class);

		#_ITEM => calcul::Total->new(0,0)}, $class);

	#my @items = map {mainWin::Controller::Item->new($_, $this)}
	my @items = map {mainWin::Controller::Item->new($_)}
		@{$categorie->get_items};
	$this->{_ITEMS} = \@items;

	return $this;
}

#sub get_model {
	#return shift->{_ITEM};
#}

sub get_nom {
	return shift->{_NOM};
}

sub get_items {
	return shift->{_ITEMS};
}

#sub set_update_ListeMatos_func {
	#my ($this, $func) = @_;
	#$this->{_UPDATE_LISTE_FUNC} = $func;
#}
#
#sub update_ListeMatos {
	#shift->{_UPDATE_LISTE_FUNC}->();
#}

1;

package administration::profilWin::Controller::Item; 

use strict;

sub new {
	#my ($class, $item, $categorie) = @_;
	my ($class, $item) = @_;
	#return bless ({_ITEM => $item, _CATEGORIE => $categorie}, $class);
	return bless ({_ITEM => $item}, $class);
	
}

#sub get_categorie {
	#return shift->{_CATEGORIE};
#}

sub get_model {
	return shift->{_ITEM};
}

sub set_model {
	my ($this, $item) = @_;
	$this->{_ITEM} = $item;
}

#appelé à chaque fois que le bouton construit dans Onglets est activé par exemple
sub on_Onglets_button_activate {
	my $controllerItem = shift;
	#my $controllerCategorie = $controllerItem->get_categorie;

	administration::profilWin::Controller::ajoute_to_profil($controllerItem->get_model->get_id);

	#$controllerCategorie->get_model->add_item($controllerItem->get_model);
	#$controllerCategorie->update_ListeMatos;
	$controllerItem->ajoute_ListeMatos;

}

sub on_Onglets_button_desactivate {
	my $controllerItem = shift;

	#my $controllerCategorie = $controllerItem->get_categorie;

#	get_total()->remove_item($controllerItem->get_model);
	#my $cat_model = $controllerCategorie->get_model();

	administration::profilWin::Controller::enleve_to_profil($controllerItem->get_model->get_id);

	#$cat_model->remove_item($controllerItem->get_model);
	#$controllerCategorie->update_ListeMatos;
	$controllerItem->delete_ListeMatos();
}

sub set_update_Onglets_func {
	my ($this, $func) = @_;
	$this->{_UPDATE_ONGLETS_FUNC} = $func;
}

sub update_Onglets {
	shift->{_UPDATE_ONGLETS_FUNC}->();
}

sub set_activate_Onglets_func {
	my ($this, $func) = @_;
	$this->{_ACTIVATE_ONGLETS_FUNC} = $func;
}

sub activate_Onglets {
	shift->{_ACTIVATE_ONGLETS_FUNC}->();
}


#appelé par mainWin::widgets::ListeMatos::ajoute pour qu'on puisse supprimer l'élément une fois qu'il a été ajouté
sub set_delete_ListeMatos_func {
	my ($this, $func) = @_;
	$this->{_DELETE_LISTE_FUNC} = $func;
}

sub delete_ListeMatos {
	shift->{_DELETE_LISTE_FUNC}->();
}

sub set_ajoute_ListeMatos_func {
	my ($this, $func) = @_;
	$this->{_AJOUTE_LISTE_FUNC} = $func;
}

sub ajoute_ListeMatos {
	shift->{_AJOUTE_LISTE_FUNC}->();
}

sub set_update_ListeMatos_func {
	my ($this, $func) = @_;
	$this->{_UPDATE_LISTE_FUNC} = $func;
}

sub update_ListeMatos {
	shift->{_UPDATE_LISTE_FUNC}->();
}

1;

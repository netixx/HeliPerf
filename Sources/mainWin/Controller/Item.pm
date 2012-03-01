#TODO: accorder les noms d'événemnt avec Controller.pm
package mainWin::Controller::Item;

use strict;
use mainWin::widgets::ListeMatos;
use mainWin::widgets::GrapheCentrage;

sub new {
	my ($class, $item, $categorie) = @_;
	return bless ({_ITEM => $item}, $class);
	#return bless ({_ITEM => $item, _CATEGORIE => $categorie}, $class);
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
	mainWin::Controller::ajoute_matos(@_);
}

sub on_Onglets_button_desactivate {
	mainWin::Controller::enleve_matos(@_);
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

sub on_SchemaHelico_drag {
	mainWin::Controller::on_SchemaHelico_drag(@_);
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

#appelé par SchemaHelico::ajoute pour qu'on puisse supprimer l'élément du matériel affiché sur le schéma
sub set_delete_SchemaHelico_func {
	my ($this, $func) = @_;
	$this->{_DELETE_SCHEMA_FUNC} = $func;
}

sub delete_SchemaHelico {
	shift->{_DELETE_SCHEMA_FUNC}->();
}

1;

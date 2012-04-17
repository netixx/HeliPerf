package changeWin::Controller;
=pod
@description
	contient l'init et les callbacks venant de l'interface
@list
	initbuild,init,on_toggled_radio,validerchangheli,annulerchangheli
@depends
	mainWin::Controller, main
=cut
use strict;

use ManageList;
use changeWin::ChargeandChange;

use constant LISTE_HELICO_NAME   => 'listehelico';#id liste helicos

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&initlist &on_toggled_radio &validerchangheli &annulerchangheli &rechargerliste);#exportation des variables pour que les fonctions puissent être appelées par le programme (limitation glade)

my $builder;

sub initlist {
	ManageList::construct_heli();
    changeWin::ChargeandChange::init();
}
#appelé par l'appui su un bouton radio
sub on_toggled_radio {
    my($cellrend,$id) = @_;#recuperation de l'id du togglebutton activé (ligne cliquée)
    changeWin::ChargeandChange::set_helico_idx_active($id);#transmission de l'id pour action
}

#appelé par le bouton 'valider'
sub validerchangheli {
	my $windowchange = $_[1];#recuperation de la fenetre
	changeWin::ChargeandChange::changerheli($windowchange);#appel de la fonction changer d'heli
}

#idem que validerchangheli pour le boutton annuler
sub annulerchangheli {
    changeWin::ChargeandChange::annulerchange();
}

1;

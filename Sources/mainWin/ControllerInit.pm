package mainWin::ControllerInit;

use strict;

use mainWin::Controller;

use constant SCHEMA_HELICO_NAME      => 'schemahelico';#id schéma hélico (haut gauche)
use constant CARBSPINKG_NAME         => 'Carbloadkg'; # identifiant spinbutton (carburant en kilo)
use constant CARBSPINLI_NAME         => 'Carbloadli';#id spinbutton (carburant en litres)
use constant CARBPROGRESS_NAME       => 'Carburantprogress'; #identifiant progress bar (carburant)
use constant MATOS_ONGLET_NAME       => 'matereqliste';#id liste du materiel equipable (haut droit)
use constant CENTOKTXT_NAME          => 'centrageok';#buffer centrage
use constant LISTE_MATOS_NAME        => "resumemat";#liste materiel equipé (bas gauche)
use constant GRAPH_CENTRAGE_NAME     => "graphecentrage";#graphe de masse et centrage (bas droit)
use constant LISTE_HELICO_NAME       => 'listehelico';#id liste des helicos treemodel
use constant LISTE_TYPE_HELICO_NAME  => 'listetypeheli';
use constant CENT_BUF_NAME           => 'centrageico';
use constant HELICOURANT_LABEL_NAME  => 'nomhelicourant';

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&calculer_le_carburant_max &get_carburant_util_kg &get_carburant_util_li &export_resume &remettre_a_zero &export_graphe_pdf);


sub init {
    my $builder = shift;
    #capture des objets de la fenetre pricipale
    my $schemahelico = $builder->get_object(SCHEMA_HELICO_NAME)
      or GenericWin::erreur_end([['erreurs','creation_schema_heli']]);
    my $notebook = $builder->get_object(MATOS_ONGLET_NAME)
      or GenericWin::erreur_end([['erreurs','creation_onglet_equip_main']]);
    my $liststore = $builder->get_object(LISTE_MATOS_NAME)
      or GenericWin::erreur_end([['erreurs','creation_tree_equip_main']]);
    my $area = $builder->get_object(GRAPH_CENTRAGE_NAME) or GenericWin::erreur_end();
    my $centbuftrans=$builder->get_object(CENTOKTXT_NAME)
      or GenericWin::erreur_end([['erreurs','creation_graphe_centrage']]);
    my $carbspinkg = $builder->get_object(CARBSPINKG_NAME)
      or GenericWin::erreur_end([['erreurs','creation_text_carbu']]);
    my $carbspinli = $builder->get_object(CARBSPINLI_NAME)
      or GenericWin::erreur_end([['erreurs','creation_text_carbu']]);
    my $carbprogress = $builder->get_object(CARBPROGRESS_NAME)
      or GenericWin::erreur_end([['erreurs','creation_jauge_carbu']]);
    my $listehelico = $builder->get_object(LISTE_HELICO_NAME)
      or GenericWin::erreur_end([['erreurs','creation_liste_heli']]);
	my $listetypehelico = $builder->get_object(LISTE_TYPE_HELICO_NAME)
      or GenericWin::erreur_end([['erreurs','creation_liste_typeheli']]);
    my $iconebuftrans = $builder->get_object(CENT_BUF_NAME)
      or GenericWin::erreur_msg([['erreurs','creation_icone_heli']]);
    #transmission au controller
    my $curheliname   = $builder->get_object(HELICOURANT_LABEL_NAME)
        or GenericWin::erreur_msg([['erreurs','creation_label_heli']]);
    mainWin::Controller::init($schemahelico, $notebook, $liststore, $area, $centbuftrans,$listehelico,$listetypehelico,$carbspinkg, $carbspinli, $carbprogress,$iconebuftrans,$curheliname);
}

=pod
description
	Controlleur->appelé par l'interface directement
	appelle la fonction de calcul du carburant maximal
requires
	mainWin::Controler::calc_carb_max
=cut
sub calculer_le_carburant_max {
  mainWin::Controller::set_carb_max();
}
sub get_carburant_util_kg {
    mainWin::widgets::Carburant::get_carburant_util_kg();
}

sub get_carburant_util_li {
    mainWin::widgets::Carburant::get_carburant_util_li();
}
sub export_resume {
    mainWin::Controller::export_ods();
}

sub remettre_a_zero {
    mainWin::Controller::raz();
}

sub export_graphe_pdf {
    mainWin::Controller::export_graphe_to_pdf();
}

1;

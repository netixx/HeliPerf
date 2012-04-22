package administration::ajouterWin::AjouterAssistPage;

use administration::widgets::ListeOptionnels;
use strict;
use Data::Dumper;
use constants::File;

use utf8;

my $oListeTypeHeli;
my $oTreeView;
my $oAssWin;
my @Notebooks;
my $oNotebooks;

sub init {
	$oListeTypeHeli = shift;
	$oNotebooks = shift;
}

sub init_assistant {
	$oAssWin = shift;
}
=pod
@description
	construit la premiere page
@return
	1)GtkVbox -> le label contenant le texte à afficher
=cut
sub intro_page {
	my $lab = Gtk2::Label->new("<big><b>\tBienvenue dans l'assistant d'ajout d'un hélicoptère</b></big>\n\tCliquez sur suivant pour continuer\n");#création du label
	$lab->set_justify('center');#texte centré
	$lab->set_line_wrap(1);#retour à la ligne possible
	$lab->set_use_markup(1);#marquage pango possible
	my $oLabEdition = Gtk2::Label->new("Pour éditer un appareil éxistant, cliquez sur le bouton :");
	$oLabEdition->set_justify('left');
	$oLabEdition->set_line_wrap(1);
	my $oBoutonEditer = Gtk2::Button->new_with_label("Édition d'un appareil");
	$oBoutonEditer->signal_connect('clicked' => \&administration::modifierWin::Controller::init );

	my $box = Gtk2::VBox->new(0,2);
	$box->pack_start($lab,1,0,1);
	my $box2 = Gtk2::HBox->new(0,2);
	$box2->pack_start($oLabEdition, 1, 0, 1);
	$box2->pack_start($oBoutonEditer, 1, 0, 1);
	$box->pack_start($box2, 1, 0, 1);
	return $box;
}

=pod
@description
	2ieme page -> choix du nom et du type d'appareil
@return
	un vbox avec plein de trucs dedans
=cut
sub nom_page {
	#labels
	my $labtitre = Gtk2::Label->new("Entrez le type et le nom de l'hélicoptère");
	my $labtype = Gtk2::Label->new("Type de l'hélicoptère");
	my $labnum = Gtk2::Label->new("Numéro de l'hélicoptère");
	#combobox -> menu déroulant
	my $combo = Gtk2::ComboBox->new_with_model($oListeTypeHeli);
	my $renderer = Gtk2::CellRendererText->new();
	$combo->pack_start($renderer,0);
	$combo->add_attribute($renderer,'text',ManageList::COL_LABEL);
	$combo->signal_connect(changed => \&administration::ajouterWin::AjouterAssist::gestion_write_combobox);

	#gtkentry->zone de texte
	my $entry = Gtk2::Entry->new();
	$entry->signal_connect(changed => \&administration::ajouterWin::AjouterAssist::valid_entry);
	#création des boites
	my $vbox = Gtk2::VBox->new(0,2);
	my $hbox = Gtk2::HBox->new(0,2);
	my $vbox1 = Gtk2::VBox->new(0,0);
	my $vbox2 = Gtk2::VBox->new(0,0);
	#on met les objets dans les boites
	$vbox1->pack_start($labtype,1,0,0);
	$vbox1->pack_start($combo,1,0,0);

	$vbox2->pack_start($labnum,1,0,0);
	$vbox2->pack_start($entry,1,0,0);

	$hbox->pack_start($vbox1,0,0,0);
	$hbox->pack_start($vbox2,0,0,0);
	$vbox->pack_start($labtitre,1,0,1);
	$vbox->pack_start($hbox,1,0,1);
	return ($vbox,$combo,$entry);
}

#page entrée de la masse et du centrage de l'hélicoptère
sub masse_et_centrage {
	#labels
	my $oLabTitre = Gtk2::Label->new("<big>Entrez la masse et le centrage de l'hélicoptère.</big>\nReportez ici les valeurs de la fiche de pesée");
	$oLabTitre->set_use_markup(1);
	$oLabTitre->set_justify('center');
	my $oLabMasse = Gtk2::Label->new(" Masse de l'hélicoptère (en kg)   ");
	my $oLabCentrage = Gtk2::Label->new(" Centrage (en mm)   "); #Entrée pour la masse
	my $oMasse = Gtk2::SpinButton->new(Gtk2::Adjustment->new(0, 0, 9999, 1, 0, 0), 1, 1);
	$oMasse->signal_connect('value-changed' => \&administration::ajouterWin::AjouterAssist::valid_nombre);
	#Entrée pour le centrage
	my $oCentrage = Gtk2::SpinButton->new(Gtk2::Adjustment->new(0, 0, 9999, 1, 0, 0), 1, 1);
	$oCentrage->signal_connect('value-changed' => \&administration::ajouterWin::AjouterAssist::valid_entry);
	#création des boites
	my $vbox = Gtk2::VBox->new(0,3);
	my $hbox = Gtk2::HBox->new(0,3);
	my $vbox1 = Gtk2::VBox->new(0,1);
	my $vbox2 = Gtk2::VBox->new(0,1);
	#on met les objets dans les boites
	$vbox1->pack_start($oLabMasse,1,0,0);
	$vbox1->pack_start($oMasse,1,0,0);

	$vbox2->pack_start($oLabCentrage,1,0,0);
	$vbox2->pack_start($oCentrage,1,0,0);

	$hbox->pack_start($vbox1,0,0,2);
	$hbox->pack_start($vbox2,0,0,2);
	$vbox->pack_start($oLabTitre,1,0,1);
	$vbox->pack_start($hbox,1,0,1);
	return ($vbox,$oMasse,$oCentrage);
}

#page de modification de la base de donnée
sub layout_adaptation_bdd_template {
	#Element utiles
	my $oLabTitre = Gtk2::Label->new("Vérifiez et corrigez les informations fournies.");
	$oLabTitre->set_justify('center');
    my $oNote = $oNotebooks->get_notebook_centrage();
	#boutons
	my $oButRegroup = Gtk2::Button->new_with_label('Ajouter un regrouppement');
	$oButRegroup->signal_connect(clicked => \&ajouter_groupe_prox);
	my $oButAdd = Gtk2::Button->new_with_label('Ajouter un item');
	$oButAdd->signal_connect(clicked => \&ajouter_item_prox);
	#boites
	my $vbox = Gtk2::VBox->new(0,3);
	my $hBoxBouton = Gtk2::HButtonBox->new();

	$hBoxBouton->pack_start($oButRegroup, 1, 0, 1);
	$hBoxBouton->pack_start($oButAdd, 1, 0, 1);
	#on met les objets dans les boites
	$vbox->pack_start($oLabTitre, 0, 0, 1);
	$vbox->pack_start($oNote, 1, 1, 1);
	$vbox->pack_start($hBoxBouton, 0, 0, 1);
	return ($vbox);
}

#chargement du type d'hélico
sub chargement_type_helico {
	my $oIterModele = shift;
	my $sModele = $oListeTypeHeli->get($oIterModele, 1);
	$sModele = Config::KeyFileManage::get_dossier_by_type($sModele);
	$oNotebooks->set_type_appareil($sModele);
}

#sub adaptation_bdd_template {
#	#on récupère le modèle de l'hélico précedement choisi ici
#	my $oIterModele = shift;
#	my $sModele = $oListeTypeHeli->get($oIterModele, 1);
#	$sModele = Config::KeyFileManage::get_dossier_by_type($sModele);
#	# le super treeview d'Ambroise ici
#	if (!chdir(main::get_base_dir()."/helicos/$sModele/")) {
#		die(main::get_base_dir());
#	}
#
#}

#configuration du choix des éléments présents lors de la pesée
sub layout_choix_present_pesee {
	my $oLabTitre = Gtk2::Label->new("Cochez les éléments présents lors de la pesée de l'appareil.");
	$oLabTitre->set_justify('center');
	my $oNote = $oNotebooks->get_notebook_present_pesee();
	#boites
	my $vbox = Gtk2::VBox->new(0,3);
	#on met les objets dans les boites
	$vbox->pack_start($oLabTitre, 0, 0, 1);
#	$vbox->pack_start($Notebooks[administration::ajouterWin::AjouterAssist::PAGE_PRESENT_PESEE], 1, 1, 1);
	$vbox->pack_start($oNote, 1, 1, 1);
	return ($vbox);
}
#
#sub choix_present_pesee {
#	#le super treeview d'Ambroise ici
#		#$oTreeView->get_listepresentpesee(get_current_notebook());
#}

#construction de la page de détermination de la configuration de base
sub layout_choix_config_base {
	my $oLabTitre = Gtk2::Label->new("Cochez les éléments qui ne sont pas enlevables de l'appareil.");
	$oLabTitre->set_justify('center');
    my $Note = $oNotebooks->get_notebook_configbase();
	#boites
	my $oLabMassePrefix = Gtk2::Label->new("Masse à vide équipée : ");
	my $oLabMasseValue = Gtk2::Label->new("0");
	my $oLabMasseSuffix = Gtk2::Label->new(" kg");
	my $hbox = Gtk2::HBox->new(0,3);
	$hbox->pack_start($oLabMassePrefix, 0, 0, 1);
	$hbox->pack_start($oLabMasseValue, 0, 0, 1);
	$hbox->pack_start($oLabMasseSuffix, 0, 0, 1);
	my $vbox = Gtk2::VBox->new(0,3);
	#on met les objets dans les boites
	$vbox->pack_start($oLabTitre, 0, 0, 1);
	$vbox->pack_start($Note, 1, 1, 1);
	$vbox->pack_start($hbox, 0, 0, 1);
	return ($vbox);
}

#
#sub choix_config_base {
#	#$oTreeView->get_listeconfigbase(get_current_notebook());
#}

#page de confirmation
sub confirm_page {
	#label
	my $lab = Gtk2::Label->new();
	return $lab;
}
#page de résumé
sub resume_page {
	#label
	my $lab = Gtk2::Label->new();
	return $lab;
}


#sub get_current_notebook {
#	return @Notebooks[$oAssWin->get_current_page()];
#}

#méthodes proxiées
sub ajouter_groupe_prox {
	administration::widgets::ajouterWin::OngletsMatos::ajoute_groupe(get_current_notebook());
}

sub ajouter_item_prox {
	administration::widgets::ajouterWin::OngletsMatos::ajoute_item(get_current_notebook());
}
1;

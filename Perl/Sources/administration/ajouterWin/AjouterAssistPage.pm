package administration::ajouterWin::AjouterAssistPage;

use strict;
use Data::Dumper;

use utf8;

my $rlistetypeheli;

sub init {
	$rlistetypeheli = shift;
}
=pod
@description
	construit la premiere page
@return
	1)GtkLabel -> le label contenant le texte à afficher
=cut
sub intro_page {
	my $lab = Gtk2::Label->new("<big><b>\tBienvenue dans l'assistant 'ajout d'un hélicoptère</b></big>\n\tCliquez sur suivant pour continuer\n");#création du label
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
	my $combo = Gtk2::ComboBox->new_with_model($$rlistetypeheli);
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


sub adaptation_bdd_template {
	#on récupère le modèle de l'hélico précedement choisi ici
	my $sModele = shift;
	#die($sModele."\n");
	#le super treeview d'Ambroise ici
	my $oTreeView = Gtk2::TreeView->new();
	return $oTreeView;
}

sub choix_present_pesee {
	#le super treeview d'Ambroise ici
	my $oTreeView = Gtk2::TreeView->new();
	return $oTreeView;
}

sub choix_config_base {
	#le super treeview d'Ambroise ici
	my $oTreeView = Gtk2::TreeView->new();
	return $oTreeView;
}

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


1;
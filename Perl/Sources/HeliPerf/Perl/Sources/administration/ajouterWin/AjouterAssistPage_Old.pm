#package administration::ajouterWin::AjouterAssistPage;

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
  return $lab;
}
=pod
@description
  construit la deuxieme page->importation
@return
  une box contenant un label et un Gtkfilchooserbutton
=cut
sub import_page {
  my $box = Gtk2::VBox->new(0,2);#boite verticale
  my $lab = Gtk2::Label->new("Si vous souhaitez créer un hélico à partir d'un hélico déjà existant, selectionner un fichier si dessous\n sinon vous pouvez cliquer sur suivant");#etiquette
  $lab->set_line_wrap(1);
  my $filchobut = Gtk2::FileChooserButton->new("Choisissez le fichier à importer",'open');
  #parametrage du filechooser
  my $filefilter = Gtk2::FileFilter->new();#filtre pour les zip
	$filefilter->add_mime_type("application/zip");#que des zip
    $filefilter->add_pattern('*.zip');#que des .zip
    $filefilter->set_name("zip file");#titre
    $filchobut->add_filter($filefilter);#ajout du filtre
    $filchobut->set_filter($filefilter);#utilisation du filtre
  $filchobut->signal_connect('file-set' => sub { administration::ajouterWin::AjouterAssist::import_assist_prepare($filchobut->get_filename()); } );
  #on met les objets dans la boite
  $box->pack_start($lab,1,0,1);
  $box->pack_start($filchobut,1,0,1);
  return $box;
}

=pod
@description
  3ieme page -> choix du nom
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
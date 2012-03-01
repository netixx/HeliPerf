package administration::ControllerInit;

use strict;

use constant SUPPRHELIWIN_NAME		=> 'supprheli';
use constant MODULEADMINWIN_NAME	=> 'moduleadministrateur';
use constant COURBESBUT_NAME		=> 'perfomodadm';
use constant AJSUPPRTYPEHELI_NAME	=> 'ajsupprtypeheli';
use constant EDITSTRING_NAME		=> 'editchainemodadm';
use constant EDITSTRING_TREE_NAME	=> 'treestring';


use administration::Controller;
use administration::profilWin::ControllerInit;
use administration::editWin::ControllerInit;
use OpenandCloseWin;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&importer_disp &save_edit &exporter_disp &modifier_disp &admin_disp &ajouter_helico_disp &supprimer_helico_load_disp &select_helico_disp &supprimer_helico_disp &ajoutersupprtypeheli_disp &edit_profil_disp &enregistrer_profil_disp &edit_strings_disp &enreg_valeurs_disp &cell_edited_disp &editer_profil_disp &ajouter_profil_disp &edit_profil_select_wremove_disp &edit_profil_select_wread_disp);#exportation des variables pour que les fonctions puissent être appelées par le programme (limitation glade)

my $builder;

sub init {
  $builder = shift;
  administration::profilWin::ControllerInit::init($builder);
  administration::editWin::ControllerInit::init($builder);
  my $treestring = $builder->get_object(EDITSTRING_TREE_NAME);
  ManageList::init_strings($treestring);
}
#callbacks pour l'appli (cf glade)
sub admin_disp {
  administration::Controller::admin();
}

sub importer_disp {
  administration::Controller::importer();
}

sub exporter_disp {
  administration::Controller::exporter();
}

sub modifier_disp {
  administration::Controller::modifier($builder);
  OpenandCloseWin::construct_and_display(main::EDITEURWIN_NAME);#on charge et affiche la fenetre de l'éditeur
}
sub ajouter_helico_disp {
  administration::Controller::ajouter_helico();
}

sub supprimer_helico_load_disp {
  administration::Controller::supprimer_helico_load();
  OpenandCloseWin::construct_and_display(SUPPRHELIWIN_NAME);#on charge et affiche la fenetre  supprimer helico
}

sub select_helico_disp {
  my $id = $_[1];#recuperation de l'id
  administration::Controller::select_helico($id);
}

sub supprimer_helico_disp {
  administration::Controller::supprimer_helico();
}

sub ajoutersupprtypeheli_disp {

}
sub edit_profil_select_wremove_disp {
  administration::Controller::edit_profil(1);
}
sub edit_profil_select_wread_disp {
  my $bar = $_[1];
  OpenandCloseWin::close_souf(undef, $bar);
  administration::Controller::edit_profil(0);
}

sub edit_strings_disp {
  administration::Controller::edit_strings();
}

sub enreg_valeurs_disp {
  administration::Controller::enreg_valeurs();
}

sub cell_edited_disp {
  my ($cell,$path,$text) = @_;
  my $content = {'path'	=> $path,
				 'text'	=> $text};
  administration::Controller::cell_edited($content);
}
sub editer_profil_disp {
  administration::profilWin::widgets::SelectProfil::_on_clicked();
}
1;

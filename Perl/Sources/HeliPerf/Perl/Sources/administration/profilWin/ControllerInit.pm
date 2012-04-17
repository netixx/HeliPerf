package administration::profilWin::ControllerInit;

use strict;

use administration::profilWin::Controller;


use constant EDITEURPROFILNOTE_NAME	=> 'Profilmatosnote';
use constant TREESTOREPROFIL_NAME	=> 'profilliste';
use constant CURPROFILLAB			=>'profilcourlab';
use constant EDITPROFILWIN_NAME		=> 'editprofil';
use constant TREEPROFILVIEW_NAME	=>'editprofilselectview';

#use base qw/Exporter/;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&enregistrer_profil_disp &ajouter_profil_disp);#exportation des variables pour que les fonctions puissent être appelées par le programme (limitation glade)


sub init {
  my $builder = shift;
  my $notebookprofil = $builder->get_object(EDITEURPROFILNOTE_NAME)#le notebook pour les item a mettre dedans
      or	GenericWin::erreur_end(['erreurs','creation_onglet_equip_prof']);
  my $liststorecurprofil = $builder->get_object(TREESTOREPROFIL_NAME)#le treestore profil courant
      or	GenericWin::erreur_end(['erreurs','creation_tree_prof']);
  my $curprofillab = $builder->get_object(CURPROFILLAB);#le label du profil a setter
  my $treeselectprofilview = $builder->get_object(TREEPROFILVIEW_NAME);
  administration::profilWin::Controller::init(EDITPROFILWIN_NAME, $liststorecurprofil, $notebookprofil, $curprofillab,$treeselectprofilview);
}

sub enregistrer_profil_disp {
	administration::profilWin::Controller::save;
	OpenandCloseWin::construct_and_hide(EDITPROFILWIN_NAME);
}

sub ajouter_profil_disp {
	administration::profilWin::Controller::ajouter_profil;
}

1;

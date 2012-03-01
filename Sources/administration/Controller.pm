package administration::Controller;

use strict;
use GenericWin;
use ManageList;
use administration::AdminWin;
use administration::ajouterWin::SupprHeli;
use administration::ajouterWin::AjouterAssist;
use administration::exportWin::Export;
use administration::importWin::Import;
use administration::profilWin::Controller;
use IO::Compress::Zip qw(zip $ZipError);

use Data::Dumper;

my $heli_dir;
my $base_dir = main::get_base_dir;
generate_zipzip();

sub admin {
  my ($auth,$super) = administration::AdminWin::adminwin();
  if ( $auth && $super eq 'admin') {
    OpenandCloseWin::construct_and_display(administration::ControllerInit::MODULEADMINWIN_NAME);
    OpenandCloseWin::construct_and_hide(administration::ControllerInit::COURBESBUT_NAME);
	OpenandCloseWin::construct_and_hide(administration::ControllerInit::AJSUPPRTYPEHELI_NAME);
    OpenandCloseWin::construct_and_hide(administration::ControllerInit::EDITSTRING_NAME);
  } elsif ($auth && $super eq 'super') {
    OpenandCloseWin::construct_and_display(administration::ControllerInit::MODULEADMINWIN_NAME);
  }
}

sub set_helidir_current {
  $heli_dir = shift;
  administration::ajouterWin::SupprHeli::init($base_dir);
  administration::exportWin::Export::init($heli_dir,$base_dir);
  administration::importWin::Import::init($heli_dir,$base_dir);
}

sub set_helidir_util {
  my $selheli = @_;
}

sub modifier {
	administration::editWin::Controller::show();
}

sub importer {
  administration::importWin::Import::importer();
}

sub exporter {
  administration::exportWin::Export::exporter();
}

sub ajouter_helico {
  administration::ajouterWin::AjouterAssist::assist();
}
sub supprimer_helico_load {
  administration::ajouterWin::SupprHeli::supprimer_helico_load();
}

sub select_helico {
  administration::ajouterWin::SupprHeli::select(shift);#transmission de l'id active
}
sub supprimer_helico {
  administration::ajouterWin::SupprHeli::supprimer_helico();
}
sub edit_profil {
	# 1 = true
	administration::profilWin::Controller::show(shift);
}

sub edit_strings {
  ManageList::fill_tree_strings();
}

sub enreg_valeurs {
  my $strings = ManageList::get_tree_strings_changed();
  Config::Strings::Controller::to_keyfile($strings);
}

sub cell_edited {
  my $content = shift;
  ManageList::edit_tree_cell($content);
}

sub generate_zipzip {
  my $typehelicos = Config::KeyFileManage::get_typehelicos();
  foreach my $typehelico (@$typehelicos) {
    my $typedir = File::Spec->catdir($base_dir,'helicos',$typehelico->{dossier});
    chdir $typedir or warn "Echec du changement de dossier";
    my $pathzip = File::Spec->catfile($base_dir,'tmp',$typehelico->{dossier}.'zip.zip');
    zip [<*.dat>] =>  $pathzip or GenericWin::erreur_msg([['erreurs','exporter_zip']]);
  }
  chdir $base_dir;
}
1;

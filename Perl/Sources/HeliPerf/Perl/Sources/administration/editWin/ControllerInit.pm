package administration::editWin::ControllerInit;
use strict;

use administration::editWin::Controller;

use constant SPIN_MASSE_HELI_NAME => 'spinmasseheli';
use constant SPIN_BRAS_HELI_NAME  => 'spinbrasheli';

use constant MATOS_ONGLET_EDITEUR_NAME	=> 'editnote';
use constant EDIT_WIN_NAME => 'Editeur';

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&save_edit &edit_ajout_group &edit_ajout_item);#exportation des variables pour que les fonctions puissent être appelées par le programme (limitation glade)

sub init {
	my $builder = shift;
	my $notebook = $builder->get_object(MATOS_ONGLET_EDITEUR_NAME);
	my $spinmasse = $builder->get_object(SPIN_MASSE_HELI_NAME);
	my $spinbras = $builder->get_object(SPIN_BRAS_HELI_NAME);
	administration::editWin::Controller::init($notebook, EDIT_WIN_NAME, $spinmasse, $spinbras);
}


sub save_edit {
  administration::editWin::Controller::save();
}

sub edit_ajout_item {
  administration::editWin::Controller::add_item();
}

sub edit_ajout_group {
    administration::editWin::Controller::add_group();
}


1;

package aideWin::ControllerInit;

use strict;

use aideWin::Controller;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&aide_button &editeurhelp);#exportation des variables pour que les fonctions puissent être appelées par le programme (limitation glade)

sub init {
    aideWin::Controller::init(shift);#transmission du builder
}

sub buttonhelp {
    aideWin::Controller::aideWin_button();
}
sub editeurhelp {
    aideWin::Controller::aideWin_editeur();
}
1;
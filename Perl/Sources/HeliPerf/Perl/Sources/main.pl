#!/usr/bin/perl -w

#TODO: faire une appli sans console
#TODO: MVC
#TODO: Alterner les couleurs des lignes dans le tableau
use strict;
use lib ('utils', 'common');

use constant XML_FILE  => "HeliMasse_interface.xml";

#definition de toutes les fenetres utiles de l'application
use constant WINDOW_MAIN_NAME    => "Helimasse0";#id fenetre principale
use constant WINDOW_APROPOS_NAME => "apropos";#id fenetre A propos

use constant EDITEURWIN_NAME     => 'Editeur';

use Gtk2 '-init';
use Glib;

use utf8;
use FindBin qw($RealBin);
use File::Spec;
use File::Path;

#recupere le répertoire courant du script
sub get_base_dir {
    return $RealBin;
}

use Config::KeyFileManage;
use OpenandCloseWin;
use GenericWin;
use prefWin::ControllerInit;
use aideWin::ControllerInit;
use administration::ControllerInit;
use administration::editWin::ControllerInit;
use mainWin::ControllerInit;
use changeWin::Controller;


#my $strings = get_strings();

#création de la fenetre pricipale
my $builder = Gtk2::Builder->new();#builder Gtk2
$builder->add_from_file(XML_FILE)  or die "Erreur lors de la lecture du fichier ".XML_FILE;#chargement du fichier glade
$builder->connect_signals(undef);#utilisation des callbacks définis dans glade
my $windowmain = $builder->get_object(WINDOW_MAIN_NAME) or die "Erreur lors de la création de la fenêtre";
#démarrage de la fenètre prinicpale
$windowmain->show_all();

#initialisation des modules
OpenandCloseWin::init($builder);#initialisation du module de création et ouverture/fermeture des fenetres->transmission du builder
administration::ControllerInit::init($builder);
GenericWin::init($windowmain);#initialisation du module d'erreur pour indiquer la fenetre parent (cf modal)
mainWin::ControllerInit::init($builder);#préchargement du controller
#administration::editWin::ControllerInit::init($builder);
GenericWin::init($windowmain);

#boucle prinicpale
Gtk2->main;

#routine de fin de Gtk
sub gtk_main_quit {
    my $tmp_dir = File::Spec->catdir(get_base_dir(),'tmp');
    rmtree($tmp_dir);
    mkdir($tmp_dir);
    Gtk2->main_quit;
    return 1;
}

#plein ecran et fin de plein ecran
sub fullscreen {
    $_[1]->fullscreen;
}
sub unfullscreen {
    $_[1]->unfullscreen;
}

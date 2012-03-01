package OpenandCloseWin;
=pod
@desription
	s'occupe de gerer l'ouverture, la fermeture
	ainsi que la création et la supression de fenetre secondaires
	qui ont été implémentés dans Glade (et présent dans le fichier xml : helimasse_interface.xml)
@list
	init,display_souf,close_souf,close_dialog,construct_and_display,construct_and_hide
=cut

use strict;

#export des fonctions pour qu'elles puissent etre appelées par l'interface (parametrage dans Glade)
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&close_souf &display_souf &close_dialog &construct_and_hide &construct_and_display &close_win);

my $builder;

#routine d'initiation
sub init {
	$builder=shift;#récupperation du builder
}

=pod
@description
	subroutine d'ouverture d'un fenètre secondaire
@param
	1) GtkWidget->widget qui emmet le signal
	2) GtkWindow->parametré en user_data dans glade
=cut
sub display_souf {
	my ($w,$windowsouf) = @_; #le premier paramètre contient par défaut le widget gtk qui à émis le signal->pas interessant, le deuxième la fenêtre à créer
	$windowsouf->show_all();#montre la fenêtre
}

=pod
@description
	subroutine de fermeture d'un fenêtre secondaire
cf display_souf
=cut
sub close_souf {
	my ($curwid,$curwin)=@_;
	$curwin->hide();
	return 1;
}

sub close_win {
	return shift->hide_on_delete();;
}

=pod
@description
	fermeture d'une fenêtre de type GtkDialog (et héritées)
@param
	1)GtkWindow(GtkDialog)->la fenêtre à fermer
=cut
sub close_dialog {
	shift->hide;
}

=pod
@description
	recupère et ferme une fenetre
@param
	1)String->nom d'une fenêtre existante dans glade (cf .xml)
@depends
	init
=cut
sub construct_and_hide  {
	my $windowname = shift;#permet de transmettre en 3ieme argument un fenetre quelconque à ouvrir
	$windowname=$builder->get_object($windowname);#construit l'objet fenetre à partir du nom de la fenetre
	$windowname->hide();
}

=pod
@description
	recupère et ouvre une fenetre
@param
	1)String->nom d'une fenêtre existante dans glade (cf .xml)
@depends
	init
=cut
sub construct_and_display  {
	my $windowname = shift;#permet de transmettre en 3ieme argument un fenetre quelconque à ouvrir
	$windowname = $builder->get_object($windowname);#construit l'objet fenetre à partir du nom de la fenetre
	$windowname->show_all();
}

1;
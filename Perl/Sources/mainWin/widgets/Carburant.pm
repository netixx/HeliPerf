package mainWin::widgets::Carburant;
#TODO: changer le nom de get_carburant_util

=pod
description
	Controlleur et vue carburant
	Module permettant de gerer l'affichage de la quantité de carburant chargé dans (afficher_carburant):
		-la progress bar
		-la zone spinbutton
	et de recuperer la valeur dans le buffer (et la progress bar ??) (recup_carb)
list
	init,afficher_carburant,get_carburant_util,calculer_le_carburant_max
=cut

use strict;

use constant COULEUR_LIMITE_NOURRICE => (.2, .5, 1);
use constant CONVERT_CARB => .8;
use Glib qw(TRUE FALSE);

######
#Widgets utilisés 
#ProgressBar(jauge)
my $carbprog;
#SpinButton en kg
my $carbspinkg;
#SpinButton en L
my $carbspinli;

# indique si la dernière modification a été effectué par le user (et non par le controller par set_carb
# afin d'empêcher le callback de rappeler le Controller (changer la valeur des spinbuttons par le programme
# balance les callbacks dans ta face)).
my $modifiedByUser = TRUE;

my $maxmasse;
my $maxvolume;
my $limite_nourrice_rat;

use Cairo;
use Gtk2;



#########################################
# Fonctions appelées par Controller.pm
#########################################
sub init {
	($carbspinkg,$carbspinli, $carbprog) = @_;
#pointer-motion-mask button1-motion-mask 
	$carbprog->add_events ([qw/button1-motion-mask button-press-mask exposure-mask/]);
	# Signals used to handle backing pixmap
	 #l'objet est passé en paramètre supplémentaire aux callbacks
	$carbprog->signal_connect_after( expose_event    => \& _prog_expose_event  );
#	$area->add_events(['pointer-motion-hint-mask','button-press-mask', 'button-release-mask']);
#	$carbprog->signal_connect( button_press_event => \&_prog_button_press);
#	$area->add_events(['pointer-motion-hint-mask','button-press-mask', 'button-release-mask']);
#	$area->signal_connect( button_press_event => \&_button_press, \$el);
#	$area->signal_connect( button_release_event => \&_button_release, \$el);
	$carbprog->signal_connect( motion_notify_event => \&_prog_button_press);
	$carbprog->signal_connect( button_press_event => \&_prog_button_press);
}

sub set_liste_carburant {
	my $listeCarburant = shift;
	set_max_kg($listeCarburant->maxmasse);
	my $limite_nourrice = $listeCarburant->get_limite_nourrice;
	if (defined($limite_nourrice)) {
		$limite_nourrice_rat = $listeCarburant->get_limite_nourrice / $maxmasse;
	}
	else {
		$limite_nourrice_rat = undef;
	}
}

sub set_masse {
	my $masse = shift;
	#empêche les callbacks de se déclencher(cf get_carburant_util) 
	set_spinkg($masse);
	set_spinli(kg_to_li($masse));
	set_prog(kg_to_rat($masse));
}

#fonction utilisée par Controller
#DEPRECATED
sub set_carb {
	set_masse(@_);
}



=pod
description
	Controlleur->envoie des infos au modèle de calcul
	Callbacks appelés lors de l'édition des spinbutton
	recupere une valeur entrée par l'utilisateur dans la zone de spinbutton
requires
	mainWin::Controller::on_Carburant_change_carb
=cut
sub get_carburant_util_kg { 
	#on ne veut pas faire tout ce bordel si on modifie par le programme (cf set_masse)
	if ($modifiedByUser) {
		my $masse = get_spinkg();
		set_spinli(kg_to_li($masse));
		set_prog(kg_to_rat($masse));
		#recuperation du texte et envoi		
		mainWin::Controller::on_Carburant_change_carb($masse);
	}
	
}

sub get_carburant_util_li {
	if ($modifiedByUser) {
		my $volume = get_spinli();
		my $masse = li_to_kg($volume);
		set_spinkg($masse);
		set_prog(li_to_rat($volume));
		mainWin::Controller::on_Carburant_change_carb($masse);
	}
}

sub _prog_button_press {
	my ($widget, $event, $el ) = @_;
	my ($x, $y) = $event->get_coords;

	my $rat = (1 - $y / $widget->allocation->height);

	if ($rat > 1) {
		$rat = 1
	}
	elsif ($rat < 0) {
		$rat = 0;
	}

	my $masse = rat_to_kg($rat);

	set_prog($rat);
	set_spinli(rat_to_li($rat));
	set_spinkg($masse);

	mainWin::Controller::on_Carburant_change_carb($masse);
	
	return Glib::TRUE;
}


#########################
# 
# About max carburant
#
#########################
sub set_max_kg {
	$maxmasse = shift;
	$maxvolume = kg_to_li($maxmasse);
	$carbspinkg->set_range(0, $maxmasse);
	$carbspinli->set_range(0, $maxvolume);
}

sub get_max_kg {
	return $maxmasse;
}

sub get_max_li {
	return $maxvolume;
}


#SpinKg
sub set_spinkg {
	$modifiedByUser = FALSE;
	$carbspinkg->set_value(shift);
	$modifiedByUser = TRUE;
}

sub get_spinkg {
	return $carbspinkg->get_value();
}


#SpinLi
sub set_spinli {
	$modifiedByUser = FALSE;
	$carbspinli->set_value(shift);
	$modifiedByUser = TRUE;
}

sub get_spinli {
	return $carbspinli->get_value();
}


#Prog
sub set_prog {
	my $ratio = shift;
	$carbprog->set_text( int($ratio*100).'%');
	$carbprog->set_fraction($ratio);
}


#######################################
# Fonctions de conversions d'unités (ça n'a rien à foutre ici mais bon)
########################################
sub kg_to_rat {
	return shift() / get_max_kg();
}

sub kg_to_li {
	return shift() / CONVERT_CARB;
}

sub li_to_kg {
	return shift() * CONVERT_CARB;
}

sub li_to_rat {
	return shift() / get_max_li();
}

sub rat_to_li {
	return shift() * get_max_li();
}

sub rat_to_kg {
	return shift() * get_max_kg();
}

sub _prog_expose_event {
	my $widget = shift;    # GtkWidget      *widget
	my $event  = shift;    # GdkEventExpose *event

	return Glib::FALSE unless $limite_nourrice_rat;

	my $cr = Gtk2::Gdk::Cairo::Context->create ($widget->window);
	$cr->set_source_rgb(COULEUR_LIMITE_NOURRICE);
	$cr->move_to(0, $widget->allocation->height * (1 - $limite_nourrice_rat));
	$cr->rel_line_to($widget->allocation->width, 0);
	$cr->stroke;

	return Glib::FALSE;
}

1;
__END__
######################################
# Convention de nommage :
# set_widget_unite
# avec widget = spinkg|spinli|prog
# unite = kg|li|rat
#
# get_widget_unite
#####################################



#SpinKg
sub set_spinkg_kg {
	$carbspinkg->set_value(shift);
}

sub set_spinkg_li {
	set_spinkg_kg(li_to_kg(shift));
}

sub get_spinkg_kg {
	return $carbspinkg->get_value();
}


#SpinLi
sub set_spinli_li {
	$carbspinli->set_value(shift);
}

sub set_spinli_kg {
	set_spinli_li(kg_to_li(shift));	
}

sub get_spinli_li {
	return $carbspinli->get_value();
}


#Prog
sub set_prog_rat {
	my $ratio = shift;
	$carbprog->set_text( int($ratio*100).'%');
	$carbprog->set_fraction($ratio);
}

sub set_prog_kg {
	set_prog_rat(kg_to_rat(shift));
}

sub set_prog_li {
	set_prog_rat(li_to_rat(shift));
}


#######################################
# Fonctions de conversions d'unités (ça n'a rien à foutre ici mais bon)
########################################
sub kg_to_rat {
	return shift() / get_max_kg();
}

sub kg_to_li {
	return shift() / CONVERT_CARB;
}

sub li_to_kg {
	return shift() * CONVERT_CARB;
}

sub li_to_rat {
	return shift() / get_max_li();
}


1;

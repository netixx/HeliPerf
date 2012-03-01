package common::widgets::Onglets;
=pod
Ce module crée les onglets de matos équippable.

init($notebook) : à l'issue, le module travaillera sur le GtkNoteBook donné en paramètre
new($base) : Crée les onglets correspondant à la base de données $base (cf plus bas) 
=cut

use strict;

use constant ONGLET_PROFIL_TITLE => 'Profils';

use constant NB_COL => 3;
use constant NB_LIG => 4;

use Gtk2;
use Glib;

#si les boutons ne remplissent pas tout l'espace s'il n'y en a moins que le max
use constant HOMOGENE => Glib::TRUE;
#Nombre de caractères
use constant TAILLE_MAX => 20;

sub new {
	my ($class, $notebook) = @_;
	return bless({ _NOTEBOOK => $notebook }, $class);
}

sub get_notebook {
	return shift->{_NOTEBOOK};
}

=pod
Pour créer les onglets, new attends en paramètre une référence vers un tableau d'objets catégorie présentant les méthodes
$cat->titre : titre de la catégorie (nom de l'onglet)
$cat->get_items : tableau des différents objets item

La classe item doit implémenter les méthodes
$item->get_nom
$item->get_masse
$item->get_bras
$item->on_Onglets_button_activate : cette méthode est appelée quand le bouton est activé
$item->on_Onglets_button_desactivate	: cette méthode est appelé quand le bouton est désactivé

Ces deux méthodes suivantes ne sont pas encore implémentés. Peut-être un beau jour..
$item->set_activate_button_func ($func) : permet au controller d'appeler la fonction $func pour simuler l'action de l'utilisateur de l'activation du bouton.
$item->set_desactivate_button_func ($func) : permet au controller d'appeler la fonction $func pour simuler l'action
	de l'utilisateur de la désactivation du bouton (si l'utilisateur supprime dans la ListeMatos).
=cut

sub set_categories {
	my ($this, $categories) = @_;
	my $notebook = $this->{_NOTEBOOK};
	my @tab_items = ();
	
	#Suppression des onglets déjà présents s'il y en a
	my $n = $notebook->get_n_pages;
	for (my $j = 0; $j < $n; $j++) {
		$notebook->remove_page(-1);
	}
	
	foreach my $categorie (@$categories) {
		my $cItems = $categorie->get_items;
		my @buttons = map {_item_to_button($_)} @$cItems;
		
		$this->append_buttons_page(\@buttons, $categorie->get_nom());
	}

}

sub append_buttons_page {
	my ($this, $buttons, $nom) = @_;

	#calcul du nombre de ligne, connaissant le nombre total à placer
	my $nbligne = int($#$buttons / NB_COL) + 1;
	#on prend minium NB_LIG quand même
	if ($nbligne < NB_LIG) { $nbligne = NB_LIG; }
	
	#Pour bien aligner les boutons
	my $table =	Gtk2::Table->new ($nbligne, NB_COL, HOMOGENE);
	#Pour mettre des barres défilantes
	my $scrolledwindow = Gtk2::ScrolledWindow->new;
	$scrolledwindow->add_with_viewport($table);
	#On affiche que la barre verticale, si nécessaire
	$scrolledwindow->set_policy ('never', 'automatic');
	
	$this->{_NOTEBOOK}->append_page ($scrolledwindow, $nom);
	
	#initialisation de la position courante dans le GtkTable.
	my @idx = _init_idx();
	foreach my $button (@$buttons) {
		#Le bouton est ajouté au GtkTable à la position @idx
		$table->attach_defaults( $button, @idx);
		#On incrémente l'index
		@idx = _incr_idx(@idx);
	}
	$scrolledwindow->show_all();
}


=pod
Fonctions utiles pour savoir où créer le bouton dans le GtkTable
=cut
sub _init_idx {
	return (0,1,0,1);
}
sub _incr_idx {
	my ($l,$r,$t,$b) = @_;
	$l++;
	if ($l == NB_COL) {
		$t++; $l = 0;
	}
	return ($l,$l+1,$t,$t+1);
}

sub _item_to_button {
	my $cItem = shift;
	my $item = $cItem->get_model;
	my $nom	 = $item->get_nom;

	my $tooltip = _get_tooltip($item->get_bras_masse);

	my ($lbl, $info) = get_suppl_tooltip($nom);
	#libéllé du bouton : $lblname
	my $button = Gtk2::ToggleButton->new($lbl);

	my $label = $button->child;
	$label->set_max_width_chars(TAILLE_MAX);
	$label->set_ellipsize('end');

	#texte de l'info bulle
	$button->set_tooltip_text("$info$tooltip");

	my $update_func = sub {
		my $masse = $item->get_masse;
		#du fait du drag & drop, il peut y avoir nombre de chiffre
		my $bras = int($item->get_bras);
		$button->set_tooltip_text($info._get_tooltip($bras, $masse));
	};

	$cItem->set_update_Onglets_func  ($update_func);
	$cItem->set_activate_Onglets_func(sub {$button->set_active(Glib::TRUE);});
	
	#Callback pour prévenir l'item qu'on a activé ou désactivé le bouton
	my $on_toggled = sub {
		if (shift->get_active) {
			$cItem->on_Onglets_button_activate;
		}
		else {
			$cItem->on_Onglets_button_desactivate;
		}
	};
	
	$button->signal_connect(toggled => $on_toggled);
	
	return $button;
}

sub _get_tooltip {
	my ($bras, $masse) = @_;
	return "Masse : $masse\nBras : $bras";

}

sub get_suppl_tooltip {
	my $nom = shift;

	#info supplémentaire à afficher dans l'infobulle
	my $info = '';
	#nom du	bouton
	my $lblname = $nom;
	
	#Si ça dépasse la taille maximale autorisé
	if (length($lblname) > TAILLE_MAX) {
		#le nom en entier n'est pas affiché
		#$lblname = substr($lblname,0,TAILLE_MAX - 3).'...';
		#du coup le nom est affiché dans l'infobulle
		$info = "$nom\n";
	}
	
	return ($lblname, $info);
}

1;

package administration::profilWin::widgets::SelectProfil;
use strict;

# Pour reconnaître la touche suppr quand on clique sur suppr justement
use Gtk2::Gdk::Keysyms;

my $treestore;
#my $window;
my $treeview;
my $categories;
#my $profils;
my $is_editable;
my $cProfils;

sub init {
	$treeview = shift;
	$treestore = $treeview->get_model();
	$treeview->signal_connect("key_press_event", \&_key_press);
	#$window = Gtk2::Window->new();
	#$window->set_modal(Glib::TRUE);
	#$treestore = Gtk2::TreeStore->new('Glib::String');
	#
	#my $treeview = Gtk2::TreeView->new_with_model($treestore);
	#my $cellrendrer = Gtk2::CellRendererText->new;
	#my $tree_column = Gtk2::TreeViewColumn->new_with_attributes ("Nom", $cellrendrer, 'text', 0);
	#$treeview->append_column($tree_column);
	#
	## Pour mettre des barres défilantes
	#my $scrolledwindow = Gtk2::ScrolledWindow->new;
	#$scrolledwindow->add($treeview);
	## On affiche que la barre verticale, si nécessaire
	#$scrolledwindow->set_policy ('never', 'automatic');
	#
	#my $vbox = Gtk2::VBox->new();
	#$vbox->add($scrolledwindow);
	#my $button = Gtk2::Button->new('Editer');
	#$button->signal_connect(clicked => sub {_on_clicked($treeview);});
	#$vbox->add($button);
	#
	#$window->add ($vbox);
	#$treeview->set_rules_hint(Glib::TRUE);
}


#my @tab_noms = ();

sub new {
	my ($categories, $cProfils_arg, $is_editable_arg) = @_;
	my @tab_noms = ();
	#@tab_noms = ();
	$treestore->clear();
	$is_editable = $is_editable_arg;
	$cProfils = $cProfils_arg;



	foreach my $categorie (@$categories) {
		my $items = $categorie->get_items;
		foreach my $mainitem (@$items) {
			$tab_noms[$mainitem->get_id] = $mainitem->get_nom;
		}

	}

	#
	# Création De L'Onglet Profil
	#

	#map { ajoute ($_) } @$profils;
	#foreach my $cProfil (@$cProfils) {
	foreach my $profil (@$cProfils) {
		#my $profil = $cProfil->get_model;
		my $iter_profil = $treestore->append(undef);
		$treestore->set($iter_profil, 0, $profil->get_nom);
		foreach my $id (@{$profil->get_ids}) {
			my $iter = $treestore->append($iter_profil);
			$treestore->set($iter, 0, $tab_noms[$id]);
		}
	}
}

sub ajoute {
	my $profil = shift;
	my $iter_profil = $treestore->append(undef);
	$treestore->set($iter_profil, 0, $profil->get_nom);
	#foreach my $id (@{$profil->get_ids}) {
		#my $iter = $treestore->append($iter_profil);
		#$treestore->set($iter, 0, $tab_noms[$id]);
	#}
}

sub _on_clicked {
	my ($treeview) = @_;
	my $nth = _get_n_selected($treeview);

	if (defined($nth)) {
		#administration::profilWin::Controller::on_SelectProfil_edit($categories, $profils, $nth);
		administration::profilWin::Controller::on_SelectProfil_edit($nth);
	}
}

sub _get_n_selected {
	#my $treeview = shift;
	my $path = $treestore->get_path(scalar($treeview->get_selection->get_selected));

	return undef unless ($path);

	my @arrindice = $path->get_indices;

	if (scalar(@arrindice) == 1) {
		return shift (@arrindice);
	}
	else {
		return undef;
	}
}

#####################################################################
# Callback de keypress sur le treeview (supprimer une ligne avec suppr)
#####################################################################
sub _key_press {
	my ($treeview, $event) = @_;
	return Glib::FALSE unless($event->keyval == $Gtk2::Gdk::Keysyms{Delete} && $is_editable);

	my $nth = _get_n_selected($treeview);

	if (defined($nth)) {
		administration::profilWin::Controller::on_SelectProfil_delete($nth);
		$treeview->get_model->remove(scalar($treeview->get_selection->get_selected));
		return Glib::TRUE;
	}
	else {
		return Glib::FALSE;
	}

}

1;

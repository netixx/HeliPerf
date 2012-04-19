package administration::widgets::ListeOptionnels;
=pod
new->($categories, $profils)
->get_categories_profils() renvoie ($categories, $profils)
->ajoute_groupe($notebook)
->ajoute_item($notebook)

->get_listecentrage
->get_listepresentpesee
-> get_listeconfigbase
renvoient des notebook

_TREESTORES [ {treestore=>, nom => } , ..]
_BASE_ITEMS
_PROFILS
=cut

# Pour reconnaître la touche suppr quand on clique sur suppr justement
use Gtk2::Gdk::Keysyms;

use models::Categorie;

use strict;

use constant ONGLET_CONFIGBASE_NAME => 'Configuration de base';
# Numéro de colonnes des attributs dans le treestore
use constant COL_NOM           => 0;
use constant COL_MASSE         => 1;
use constant COL_BRAS          => 2;
use constant COL_BRAS_L        => 3;
use constant COL_IMG           => 4;
# Boolean indiquant si l'item n'est qu'un simple item (pas un models::MainItem)
use constant COL_EST_ITEM      => 5;
use constant COL_GRAS          => 6;
use constant COL_PRESENT_PESEE => 7;
use constant COL_DRAGABLE      => 8;
use constant COL_ID            => 9;
use constant COL_EST_TOP      => 10;
use constant COL_CONFIG_BASE => 11;

#A accorder avec ci-dessus (dans le même ordre)
use constant LISTE_COL_TYPES  => ('Glib::String', 'Glib::Int', 'Glib::Int',
    	'Glib::Int', 'Glib::String', 'Glib::Boolean', 'Glib::Int', 'Glib::Boolean',
	'Glib::Boolean', 'Glib::Int', 'Glib::Boolean', 'Glib::Boolean');

use constant GRAS_NORMAL => 400;
use constant GRAS_MAIN   => 800;

use constant INVALID_ID => -1;
######## FONCTIONS DEPRECACTED

##########################
#
# Fonctions appelées par le controller
#
##########################

# c'est mal foutu certes.
#Bouton ajouter un regoupement (mainitem) cliqué
=pod
@param $notebook
=cut
sub ajoute_groupe {
#	my $this = shift;
	my $treeview = _get_current_treeview(shift);
	my $treestore = $treeview->get_model;
	my $iter = _append_mainitem($treestore);
	_start_edit_path($treeview, $treestore->get_path($iter));
}

=pod
@param $notebook
=cut
sub ajoute_item {
	my $treeview = _get_current_treeview(shift);
	my $treestore = $treeview->get_model;
	my $iter = _append_item($treestore);
	_start_edit_path($treeview, $treestore->get_path($iter));
}


sub new {
	my ($class, $categories, $profils, $config_base) = @_;
	my $this = {_PROFILS => $profils};

	# id => [profils associés]
	my @base_items = ();
	my @treestores = ();

	######################################################
	#
	# Construction des onglets de matos
	#
	######################################################
	foreach my $categorie (@$categories) {
		my $items = $categorie->get_items;
		map { $base_items[$_->get_id] = [] } @$items;

		push @treestores, { treestore => _create_treestore($items),
			nom => $categorie->get_nom };

	}

	######################################################
	#
	# Construction des relations avec les profils
	#
	######################################################
	foreach my $profil (@$profils) {
		foreach my $id (@{$profil->get_ids}) {
			push @{$base_items[$id]}, $profil;
		}
	}

	$this->{_BASE_ITEMS} = \@base_items;
	$this->{_TREESTORES} = \@treestores;
	return bless($this, $class);

}

sub get_listecentrage {
	my ($this, $notebook) = @_;
	return $this->get_liste($notebook, COL_NOM, COL_MASSE, COL_BRAS, COL_IMG);
}
sub get_listepresentpesee {
	my ($this, $notebook) = @_;
	return $this->get_liste($notebook, COL_NOM, COL_MASSE, COL_PRESENT_PESEE);
}
sub get_listeconfigbase {
	my ($this, $notebook) = @_;
	return $this->get_liste($notebook, COL_NOM, COL_MASSE, COL_CONFIG_BASE, COL_DRAGABLE);
}

sub get_liste {
	my $this = shift;
	my $notebook = shift;

	if ($notebook) {
		# Suppression des onglets déjà présents s'il y en a
		my $n = $notebook->get_n_pages;
		for (my $j = 0; $j < $n; $j++) {
			$notebook->remove_page(-1);
		}
	}
	else {
	 	$notebook = Gtk2::Notebook->new;
	}
	
	my @listecols = @_;

	######################################################
	#
	# Construction des onglets de matos
	#
	######################################################
	foreach my $cat (@{$this->{_TREESTORES}}) {
		my $treestore = $cat->{treestore};
		my $treeview  = Gtk2::TreeView->new_with_model($treestore);
		map {$treeview->append_column(_create_column($treestore, $_)); } @listecols;

		my $entry = ['ligne', 'GTK_TARGET_SAME_WIDGET', 0];
		$treeview->enable_model_drag_source( 'button1-mask', ['move', 'default'], $entry);
		$treeview->enable_model_drag_dest(['default'],  $entry );

		#cet iter est celui qui est couramment dragué. On l'initialise avec une valeur au pif
		#pour pouvoir faire $drag_iter->set($niter) dans _drag_get
		my $drag_iter = $treestore->get_iter_first;

		$treeview->signal_connect("drag_data_get", \&_drag_get, $drag_iter);
		$treeview->signal_connect("drag_data_received", \&_drag_received, [$drag_iter, $this->{_BASE_ITEMS}]);
		$treeview->signal_connect("drag_data_delete", \&_drag_delete, $drag_iter);
		#Qu'on puisse supprimer quoi. Une ligne avec la touche suppr quoi.
		$treeview->signal_connect("key_press_event", \&_key_press, $this->{_BASE_ITEMS});

		# Pour mettre des barres défilantes
		my $scrolledwindow = Gtk2::ScrolledWindow->new;
		$scrolledwindow->add($treeview);
		# On affiche les barres de défilement si nécessaire
		$scrolledwindow->set_policy ('automatic', 'automatic');


		$notebook->append_page ($scrolledwindow, $cat->{nom});

		$scrolledwindow->show_all();
		$treeview->set_rules_hint(Glib::TRUE);
	}
	return $notebook;
}

sub _create_column {
	my $treestore = shift;
	my $nCol = shift;
	return _new_col_editable($treestore, 'Nom', COL_NOM)                              if $nCol == COL_NOM;
	return _new_col($treestore, 'Masse', COL_MASSE, COL_EST_ITEM)                     if $nCol == COL_MASSE;
	return _new_col($treestore, 'Bras', COL_BRAS, COL_EST_ITEM)                       if $nCol == COL_BRAS;
	return _new_col($treestore, 'Bras latéral', COL_BRAS_L, COL_EST_ITEM)             if $nCol == COL_BRAS_L;
	return _new_col_editable($treestore, 'Image', COL_IMG)                            if $nCol == COL_IMG;
	return _new_col_toggle_may_visible($treestore,
		'Présent en pesée', COL_PRESENT_PESEE, COL_EST_ITEM)                      if $nCol == COL_PRESENT_PESEE;
	return _new_col_toggle_may_visible($treestore,
		'Déplaçable', COL_DRAGABLE, COL_EST_TOP)                                  if $nCol == COL_DRAGABLE;
	return _new_col_toggle_may_visible($treestore,
		'Présent dans la configuration de base', COL_CONFIG_BASE, COL_EST_TOP)    if $nCol == COL_CONFIG_BASE;
}

sub _create_treestore {
	my $items = shift;

	my $treestore = Gtk2::TreeStore->new(LISTE_COL_TYPES);

	foreach my $mainitem (@$items) {
		my $mainiter = $treestore->append(undef);
		$treestore->set($mainiter, COL_NOM,   $mainitem->get_nom,
				COL_MASSE, $mainitem->get_masse,
				COL_BRAS,  $mainitem->get_bras,
				COL_BRAS_L,$mainitem->get_bras_l,
				COL_IMG,   $mainitem->get_img,
				COL_PRESENT_PESEE, $mainitem->is_present_pesee,
				COL_CONFIG_BASE, $mainitem->is_config_base,
				COL_DRAGABLE, $mainitem->is_dragable,
				COL_ID, $mainitem->get_id,
				COL_EST_TOP, Glib::TRUE);
		my $sousitems = $mainitem->get_items;
		if (scalar(@$sousitems)) {
			$treestore->set($mainiter, COL_EST_ITEM, Glib::FALSE, COL_GRAS, GRAS_MAIN);
			foreach my $item (@$sousitems) {
				my $iter = $treestore->append($mainiter);
				$treestore->set($iter, COL_NOM,   $item->get_nom,
				COL_MASSE, $item->get_masse,
				COL_BRAS,  $item->get_bras,
				COL_BRAS_L,$item->get_bras_l,
				COL_IMG,   $item->get_img,
				COL_EST_ITEM, Glib::TRUE,
				COL_GRAS,   GRAS_NORMAL,
				COL_PRESENT_PESEE, $item->is_present_pesee,
				COL_CONFIG_BASE, $item->is_config_base,
				COL_DRAGABLE, $item->is_dragable,
				COL_ID, INVALID_ID,
				COL_EST_TOP, Glib::FALSE);
			}
		}
		else {
			$treestore->set($mainiter, COL_EST_ITEM, Glib::TRUE, COL_GRAS, GRAS_NORMAL);
		}

	}

	return $treestore;
}



sub get_categories_profils {
	my $this = shift;
	my @base = ();
	my @base_items = ();

	# la première page est la config de base : on s'en tape
	foreach my $cat (@$this->{_TREESTORES}) {
		my $nom = $cat->{nom};
		my $treestore = $cat->{treestore};

		my @tab_item = ();

		for (my $mainiter = $treestore->get_iter_first; $mainiter; $mainiter = $treestore->iter_next($mainiter)) {
			my $mainitem = models::MainItem->new(
				$treestore->get($mainiter, COL_BRAS, COL_MASSE, COL_NOM, COL_BRAS_L,
					COL_IMG, COL_PRESENT_PESEE, COL_DRAGABLE, COL_CONFIG_BASE));

			my $id = $treestore->get($mainiter, COL_ID);
			$base_items[$id] = $mainitem unless ($id == INVALID_ID);

			push @tab_item, $mainitem;
			for (my $iter = $treestore->iter_children($mainiter); $iter; $iter = $treestore->iter_next($iter)) {
				#print $treestore->get($iter,COL_NOM). ' '.$treestore->get($iter,COL_PRESENT_PESEE)."\n";
				$mainitem->add_item(models::Item->new(
					$treestore->get($iter, COL_BRAS, COL_MASSE, COL_NOM, COL_BRAS_L,
						COL_IMG, COL_PRESENT_PESEE, COL_DRAGABLE, COL_CONFIG_BASE)));
			}
		}

		push @base, models::Categorie->new($nom, \@tab_item);
	}

	calcul::Id::auto_set_categories(\@base);

	foreach my $profil (@$this->{_PROFILS}) {
		my @ids = ();
		foreach my $id (@{$profil->get_ids}) {
			my $item = $base_items[$id];
			#s'il n'a pas été supprimé
			if ($item) {
				push @ids, $base_items[$id]->get_id ;
			}
		}
		$profil->set_ids(\@ids);
	}

	return (\@base, $this->{_PROFILS});
}


##################################
#
# Callbacks
#
#
#
##################################

#################################
# Callbacks de drag & drop pour le treeview
###################################"
sub _drag_received {
	my ($treeview, $context, $x, $y, $selection, $info, $etime, $args) = @_;
	my ($drag_iter, $base_items) = @$args;
	my ($path, $position) = $treeview->get_dest_row_at_pos($x, $y);
	my $treestore = $treeview->get_model;
	my $niter;

	if ($position) {
		my $iter  = $treestore->get_iter($path);
		my $depth = $path->get_depth();
		my $is_from_main_item = ( $treestore->get($drag_iter, COL_EST_ITEM) == Glib::FALSE);
		my $is_to_main_item = ($treestore->get($iter, COL_EST_ITEM) == Glib::FALSE);

		if ($depth == 2 && $is_from_main_item){
			$context->finish(Glib::FALSE, Glib::FALSE, $etime);
			return;
		}

		if ($position eq 'before') {
			$niter = $treestore->insert_before(undef, $iter);
		}
		elsif ($position eq 'after') {
			$niter = $treestore->insert_after(undef, $iter);
		}
		else {
			#into-

			if($position eq 'into-or-before') {
				if ($depth == 2) {
					if (_is_drop_accepted($treeview, $drag_iter, $base_items)) {
						$niter = $treestore->insert_before(undef, $iter);
					}
					else {
						$context->finish(Glib::FALSE, Glib::FALSE, $etime);
						return;
					}
				}
				elsif ($is_from_main_item || !$is_to_main_item) {
					$niter = $treestore->insert_before(undef, $iter);
				}
				else {
					if (_is_drop_accepted($treeview, $drag_iter)) {
						_add_iter($treestore, $iter, $drag_iter, $base_items);
						$niter = $treestore->insert_before($iter, undef);
					}
					else {
						$context->finish(Glib::FALSE, Glib::FALSE, $etime);
						return;
					}
				}
			}
			else {#if ($position eq 'into-or-after') {
				if ($depth == 2) {
					if (_is_drop_accepted($treeview, $drag_iter, $base_items)) {
						$niter = $treestore->insert_after(undef, $iter);
					}
					else {
						$context->finish(Glib::FALSE, Glib::FALSE, $etime);
						return;
					}
				}
				elsif ($is_from_main_item || !$is_to_main_item) {
					$niter = $treestore->insert_after(undef, $iter);
				}
				else {
					if (_is_drop_accepted($treeview, $drag_iter, $base_items)) {
						_add_iter($treestore, $iter, $drag_iter);
						$niter = $treestore->insert_after($iter, undef);
					}
					else {
						$context->finish(Glib::FALSE, Glib::FALSE, $etime);
						return;
					}
				}
			}
		}
		_add_iter($treestore, $treestore->iter_parent($iter), $drag_iter) if ($depth == 2);
	}
	else {
		$niter = $treestore->append(undef);
	}

	_copy_node($treestore, $drag_iter, $niter); #$treestore->set($niter, COL_NOM, $treestore->get($drag_iter, COL_NOM));

	if ($treestore->iter_parent($niter)) {
		#my $id = $treeview->get_model->get($drag_iter, COL_ID);
#
		#if ($id != INVALID_ID) {
#
			#my $hash = $base_items[$id];
			#my $liste_profils = $hash->{profils};
			##true
#
			#if (scalar(@$liste_profils)) {
				#my $str = join ( ', ', map { $_->get_nom } @$liste_profils );
				##foreach my $profil (@$liste_profils) {
					##$str .= $profil->get_nom.", ";
				##}
				#my $dialog = Gtk2::MessageDialog->new (undef, 'modal', 'question', 'yes-no',
					#'Cet optionnel ne sera plus lié aux profils suivants : '.$str.'. Êtes-vous sûr de vouloir le déplacer ?');
#
				#if ($dialog->run() eq 'yes') {
					##$model->remove($iter);
					#delete $hash->{item};
				#}
				#else {
					#$dialog->destroy();
					#$context->finish(Glib::FALSE, Glib::FALSE, $etime);
					#return;
				#}
				#$dialog->destroy();
#
			#}
		#}
		$treestore->set($niter, COL_EST_TOP, Glib::FALSE, COL_ID, INVALID_ID);
	}
	else {
		$treestore->set($niter, COL_EST_TOP, Glib::TRUE);
	}

	$context->finish(Glib::TRUE, Glib::TRUE, $etime) if ($context->action eq 'move');
}

#renvoie undef si pas possible
sub _is_drop_accepted {
	my ($treeview, $drag_iter, $base_items) = @_;
	my $id = $treeview->get_model->get($drag_iter, COL_ID);

	return 1 if ($id == INVALID_ID);


	my $hash = $base_items->[$id];
	my $liste_profils = $hash->{profils};
	#true

	return 1 unless (scalar(@$liste_profils));

	my $str = join ( ', ', map { $_->get_nom } @$liste_profils );
	#foreach my $profil (@$liste_profils) {
		#$str .= $profil->get_nom.", ";
	#}
	my $dialog = Gtk2::MessageDialog->new (undef, 'modal', 'question', 'yes-no',
		'Cet optionnel ne sera plus lié aux profils suivants : '.$str.'. Êtes-vous sûr de vouloir le déplacer ?');
	my $ret = $dialog->run();
	$dialog->destroy();

	if ($ret eq 'yes') {
		delete $hash->{item};
		return 1;
	}
	else {
		return 0;
	}

}

sub _drag_get {
	my ($treeview, $context, $selection, $target_id, $etime, $drag_iter) = @_;
	my ($model, $iter) =  $treeview->get_selection()->get_selected;
	$drag_iter->set($iter);
}

sub _drag_delete {
	my ($treeview, $context, $drag_iter) = @_;
	my $treestore = $treeview->get_model;
	my $dest_iter = $treestore->iter_parent ($drag_iter);
	if ($dest_iter) {
		_remove_iter($treestore, $dest_iter, $drag_iter);
	}
}


#####################################################################
# Callback de keypress sur le treeview (supprimer une ligne avec suppr)
#####################################################################
sub _key_press {
	my ($treeview, $event, $base_items) = @_;
	return Glib::FALSE unless($event->keyval == $Gtk2::Gdk::Keysyms{Delete});

	my ($model, $iter) =  $treeview->get_selection()->get_selected;

	if ($iter) {
		my $id = $treeview->get_model->get($iter, COL_ID);

		if ($id == INVALID_ID) {
			$model->remove($iter);
			return Glib::TRUE;
		}

		my $hash = $base_items->[$id];
		my $liste_profils = $hash->{profils};

		if (scalar(@$liste_profils)) {
			my $str = join ( ', ', map { $_->get_nom } @$liste_profils );
			my $dialog = Gtk2::MessageDialog->new (undef, 'modal', 'question', 'yes-no',
				'Cet optionnel est lié aux profils suivants : '.$str.'. Êtes-vous sûr de vouloir le supprimer ?');

			if ($dialog->run() eq 'yes') {
				$model->remove($iter);
				delete $hash->{item};
			}
			$dialog->destroy();

		}
		else {
			$model->remove($iter);
		}
	}
	return Glib::TRUE;

}

####################################################################
#
#
# Fonctions pour faciliter la création de treeview
#
#
####################################################################

# Créer une nouvelle colonne toujours éditable
sub _new_col_editable {
	my ($treestore, $nom, $col) = @_;
	my $cellrendrer = _new_renderer($treestore, $col);
	$cellrendrer->set(editable => Glib::TRUE);
	return (Gtk2::TreeViewColumn->new_with_attributes ($nom, $cellrendrer, 'text', $col, 'weight', COL_GRAS));
}

# Créer une nouvelle colonne éditable selon la colonne $coleditable
sub _new_col {
	my ($treestore, $nom, $col, $coleditable) = @_;
	my $cellrendrer = _new_renderer($treestore, $col);
	my $tree_column = Gtk2::TreeViewColumn->new_with_attributes ($nom, $cellrendrer,
		'text', $col, 'editable', $coleditable,	'weight', COL_GRAS);
	return $tree_column;
}

sub _new_col_toggle {
	my ($treestore, $nom, $col) = @_;
	my $cellrendrer = _new_renderer_toggle($treestore, $col);
	$cellrendrer->set(activatable => Glib::TRUE);
	return (Gtk2::TreeViewColumn->new_with_attributes ($nom, $cellrendrer, 'active', $col));
}

sub _new_col_toggle_may_visible {
	my ($treestore, $nom, $col, $col_visible) = @_;
	my $cellrendrer = _new_renderer_toggle($treestore, $col);
	$cellrendrer->set(activatable => Glib::TRUE);
	return (Gtk2::TreeViewColumn->new_with_attributes ($nom, $cellrendrer, 'active', $col, 'visible', $col_visible));
}
#Créer un nouveau CellRendererText avec le callbaack qui le modifie effectivement en cas d'édition
sub _new_renderer {
	my ($treestore, $col) = @_;
	my $cellrendrer = Gtk2::CellRendererText->new;
	my $func   = sub {
		my ($cellrenderertext, $path, $new_text) = @_;
		my $iter = $treestore->get_iter_from_string($path);

		my $dest_iter = $treestore->iter_parent ($iter);
		if ($dest_iter) {
			_remove_iter($treestore, $dest_iter, $iter);
		}

		$treestore->set($iter, $col, $new_text);

		if ($dest_iter) {
			_add_iter($treestore, $dest_iter, $iter);
		}
	};
	$cellrendrer->signal_connect('edited',  $func);
	#je sais pas trop ce que ça fait tiens
	$cellrendrer->set(weight_set => Glib::TRUE);

	return $cellrendrer;
}

sub _new_renderer_toggle {
	my ($treestore, $col) = @_;
	my $cellrendrer = Gtk2::CellRendererToggle->new;
	my $func   = sub {
		my ($cellrenderertext, $path, $new_text) = @_;
		my $iter = $treestore->get_iter_from_string($path);
		$treestore->set($iter, $col, not $treestore->get($iter, $col));
		#print $treestore->get($iter,COL_NOM). ' '.$treestore->get($iter,COL_PRESENT_PESEE)."\n";
	};
	$cellrendrer->signal_connect('toggled',  $func);
	return $cellrendrer;
}


###########
# autres
##########"
=pod
@param $notebook
=cut
sub _get_current_treeview {
	my $notebook = shift;
	return $notebook->get_nth_page($notebook->get_current_page)->child;
}

#lancer l'édition automatique lors du click sur les boutons (cf ajoute_item)
sub _start_edit_path {
	my ($treeview, $path) = @_;
	$treeview->set_cursor ($path, $treeview->get_column (COL_NOM), Glib::TRUE);
}

####################################################################
#
#
# Fonctions pour manipuler le treestore
#
#
####################################################################

#mainitem == regroupement
sub _is_main_item {
	my ($treestore, $iter) = @_;
	return ($treestore->get($iter, COL_EST_ITEM) == Glib::FALSE);
}

sub _append_mainitem {
	my $treestore = shift;
	my $niter = $treestore->append(undef);
	$treestore->set($niter, COL_EST_ITEM, Glib::FALSE, COL_GRAS, GRAS_MAIN, COL_EST_TOP, Glib::TRUE, COL_ID, INVALID_ID);
	return $niter;
#libération des resourcee
}

sub _append_item {
	my $treestore = shift;
	my $niter = $treestore->append(undef);
	$treestore->set($niter, COL_EST_ITEM, Glib::TRUE, COL_EST_TOP, Glib::TRUE, COL_GRAS, GRAS_NORMAL, COL_ID, INVALID_ID);
	return $niter;
}


sub _copy_node {
	my ($treestore, $from, $to) = @_;
	my @arr = $treestore->get($from);
	my @arg = ();

	for (my $i = 0; $i < scalar(@arr); $i++) {
		push @arg, $i, $arr[$i];
	}

	$treestore->set($to, @arg);

	for (my $iter=$treestore->iter_children($from); $iter; $iter = $treestore->iter_next($iter)) {
		my $toiter = $treestore->append($to);
		_copy_node($treestore, $iter, $toiter);
	}
}


sub _add_iter {
	my ($treestore, $dest_iter, $iter) = @_;
	my ($dest_masse, $dest_bras, $dest_bras_l) = $treestore->get($dest_iter, COL_MASSE, COL_BRAS, COL_BRAS_L);
	my ($from_masse, $from_bras, $from_bras_l) = $treestore->get($iter     , COL_MASSE, COL_BRAS, COL_BRAS_L);
	my ($bras, $masse) = calcul::Centrage::ajoute_masse($dest_bras  , $dest_masse, $from_bras , $from_masse);
	my ($bras_l) =  calcul::Centrage::ajoute_masse($dest_bras_l, $dest_masse, $from_bras_l, $from_masse);

	$treestore->set($dest_iter, COL_BRAS, $bras, COL_MASSE, $masse, COL_BRAS_L, $bras_l);
}


sub _remove_iter {
	my ($treestore, $dest_iter, $iter) = @_;
	my ($dest_masse, $dest_bras, $dest_bras_l) = $treestore->get($dest_iter, COL_MASSE, COL_BRAS, COL_BRAS_L);
	my ($from_masse, $from_bras, $from_bras_l) = $treestore->get($iter     , COL_MASSE, COL_BRAS, COL_BRAS_L);
	my ($bras, $masse) = calcul::Centrage::enleve_masse($dest_bras  , $dest_masse, $from_bras , $from_masse);
	my ($bras_l) = calcul::Centrage::enleve_masse($dest_bras_l, $dest_masse, $from_bras_l, $from_masse);

	$treestore->set($dest_iter, COL_BRAS, $bras, COL_MASSE, $masse, COL_BRAS_L, $bras_l);
}

1;

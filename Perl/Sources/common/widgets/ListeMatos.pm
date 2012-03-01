package common::widgets::ListeMatos;

# s'occupe de gérer la liste du matos équipé
#TODO: ligne supprimable

=pod
S'occupe de gérer la liste du matos équipé (interface + total)
L'objet $total (cf ListeMatos::TotalItem) contient le total
L'objet $treestore (GtkListStore) fait l'interface.

init($treestore) : à l'issue, le module travaillera sur le GtkListStore donné en paramètre
new : efface tout, crée une ligne totale.
ajoute : ajoute un item à la liste
total : renvoie l'objet total (cf ListeMatos::TotalItem plus bas)
to_array : renvoie un tableau correspondant aux donnés stockés dans ListStore (la première ligne contient le nom des colonnes)

=cut

use strict;

use Gtk2;
use Glib qw(TRUE);

#Une colonne permet de déterminer si le texte est en gras (pour la ligne totale)
use constant FONT_GRAS => 800;
use constant FONT_NORMAL => 400;

use constant COL_NOM		=> 0;
use constant COL_MASSE	=> 1;
use constant COL_BRAS	 => 2;
use constant COL_MOMENT => 3;
use constant COL_FONT	 => 4;



sub new {
	my ($class, $treestore) = @_;
	return bless({ _TREESTORE => $treestore }, $class);
}

sub set_categories {
	my ($this, $categories) = @_;
	my $treestore = $this->{_TREESTORE};
	#efface toutes les données de la liste
	$treestore->clear;
	
	foreach my $categorie (@$categories) {
		my $cat_iter = $treestore->append(undef);

		$this->set_values($cat_iter, 0, 0, $categorie->get_nom, TRUE);
		#$this->set_update_func($categorie, $cat_iter);

		my $items = $categorie->get_items();
		foreach my $controllerItem (@$items) {
			my $func = sub {
				$this->_ajoute_citem($controllerItem, $cat_iter);
			};
			$controllerItem->set_ajoute_ListeMatos_func($func);
		}

	}

}

sub get_treestore {
	return shift->{_TREESTORE};
}


sub set_update_func {
	my ($this, $citem, $iter) = @_;
	$citem->set_update_ListeMatos_func(sub {$this->_update_item($citem->get_model, $iter); }); 
}




=pod
Synchronise les donnés de la dernière ligne total avec l'objet total
=cut

#Mets à jour la ligne $iter du GtkListStore $treestore
sub set_values {
	my ($this, $iter, $bras, $masse, $nom, $is_gras) = @_;
	my $font = $is_gras ? FONT_GRAS : FONT_NORMAL;

	#$font = FONT_NORMAL unless defined($font);
	$this->{_TREESTORE}->set ($iter, COL_NOM , $nom,
		COL_MASSE, $masse,
		COL_BRAS, $bras,
		COL_MOMENT, $masse * $bras,
		COL_FONT, $font);
}



sub to_array {
	my $this = shift;
	my $treestore = $this->{_TREESTORE};

	my @array = (['Nom', 'Masse','Bras', 'Moment']);
	
	for  (my $parent_iter = $treestore->get_iter_first; $parent_iter; $parent_iter = $treestore->iter_next($parent_iter)) {
		if ($treestore->iter_has_child($parent_iter)) {
			for (my $iter = $treestore->iter_children($parent_iter); $iter; $iter = $treestore->iter_next($iter)) {
				push @array, [ $treestore->get($iter, COL_NOM, COL_MASSE, COL_BRAS, COL_MOMENT) ];
			}
		}
		elsif ($treestore->get($parent_iter, COL_MASSE) != 0) {
			push @array, [ $treestore->get($parent_iter, COL_NOM, COL_MASSE, COL_BRAS, COL_MOMENT) ];
		}
	}

	return \@array;

}



sub _update_item {
	my ($this, $item, $iter) = @_;
	my @bras_masse = $item->get_bras_masse;
	
	my $cat_iter = $this->{_TREESTORE}->iter_parent($iter);

	if ($cat_iter) {
		$this->_set_bras_masse($cat_iter, calcul::Centrage::rafraichir_masse($this->_get_bras_masse($cat_iter),
			$this->_get_bras_masse($iter), @bras_masse));
	}

	$this->_set_bras_masse($iter, @bras_masse);
}

sub _ajoute_citem {

	my ($this, $controllerItem, $cat_iter) = @_;
	my $treestore = $this->{_TREESTORE};
	
	my $item = $controllerItem->get_model;
	my $iter = $treestore->append ($cat_iter);	
	{
		my $nom	 = $item->get_nom;
		my @bras_masse = $item->get_bras_masse;
		
		#mise à jour de la catégorie
		$this->_set_bras_masse($cat_iter, calcul::Centrage::ajoute_masse(
			$this->_get_bras_masse($cat_iter), @bras_masse));
		
		#Ajout dans le GtkListStore
		$this->set_values($iter, @bras_masse, $nom);
	}

	foreach my $sousitem (@{$item->get_items}) {
	
		my $nom	 = $sousitem->get_nom	;
		my $masse = $sousitem->get_masse;
		my $bras = $sousitem->get_bras ;	
		
		#Ajout dans le GtkListStore
		my $sousiter = $treestore->append ($iter);	
		$this->set_values($sousiter, $bras, $masse, $nom);

	}

	$controllerItem->set_delete_ListeMatos_func(sub {$this->_enleve_iter($iter)});
	$this->set_update_func($controllerItem, $iter);
}

sub _enleve_iter {
	my ($this, $iter) = @_;
	my $cat_iter = $this->{_TREESTORE}->iter_parent($iter);
	#mise à jour de la catégorie
	if ($cat_iter) {
		$this->_set_bras_masse($cat_iter, calcul::Centrage::enleve_masse(
			$this->_get_bras_masse($cat_iter),
			$this->_get_bras_masse($iter)));
	}

	$this->{_TREESTORE}->remove($iter);

}

sub _get_bras_masse {
	my ($this, $iter) = @_;
	return $this->{_TREESTORE}->get($iter, COL_BRAS, COL_MASSE);
}

sub _set_bras_masse {
	my ($this, $iter, $bras, $masse) = @_;
	$this->{_TREESTORE}->set($iter, COL_BRAS, $bras, COL_MASSE, $masse, COL_MOMENT, $masse * $bras);
}
1;

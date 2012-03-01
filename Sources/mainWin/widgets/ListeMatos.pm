package mainWin::widgets::ListeMatos;

use common::widgets::ListeMatos;
use constant CONFIG_BASE_NAME => 'Configuration de base';
use constant VIDE_NAME => 'Helico à vide';

my $wListeMatos;

sub init {
	$wListeMatos = common::widgets::ListeMatos->new(shift);
}

sub new {
	my ($helico, $controllerCarburant, $controllerTotal, $categories) = @_;
	#efface toutes les données de la liste
	$wListeMatos->set_categories($categories);

	my $treestore = $wListeMatos->get_treestore;

	my $item = $controllerCarburant->get_model;
	#Ajout dans le GtkTreeStore
	my $iter = $treestore->prepend (undef);	
	$wListeMatos->set_values($iter, $item->get_bras_masse, $item->get_nom);
	$wListeMatos->set_update_func($controllerCarburant, $iter);


	my $helico_iter = $treestore->prepend(undef);
	$wListeMatos->set_values($helico_iter, $helico->get_bras_masse, $helico->get_nom);

	my $vide_iter = $treestore->append($helico_iter);
	$wListeMatos->set_values($vide_iter, $helico->get_bras_masse_vide, VIDE_NAME);

	my $config_iter = $treestore->append($helico_iter);
	my @bras_masse_vide = (0, 0);

	foreach my $item (@{$helico->get_config_base}) {
		my $iter = $treestore->append($config_iter);
		$wListeMatos->set_values($iter, $item->get_bras_masse, $item->get_nom);

		@bras_masse_vide = calcul::Centrage::ajoute_masse(@bras_masse_vide, $item->get_bras_masse);
	}

	$wListeMatos->set_values($config_iter, @bras_masse_vide, CONFIG_BASE_NAME);
	
	my $total_iter = $treestore->append(undef);
	#1 = TRUE : on met en gras
	$wListeMatos->set_values($total_iter, $controllerTotal->get_model->get_bras_masse, 'Total', 1);
	$wListeMatos->set_update_func($controllerTotal, $total_iter);
}

sub to_array {
	return $wListeMatos->to_array;
}
1;
__END__
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

#Une colonne permet de déterminer si le texte est en gras (pour la ligne totale)
use constant FONT_GRAS => 800;
use constant FONT_NORMAL => 400;

use constant COL_NOM		=> 0;
use constant COL_MASSE	=> 1;
use constant COL_BRAS	 => 2;
use constant COL_MOMENT => 3;
use constant COL_FONT	 => 4;

#Le GtkListStore
my $treestore;

my $lastiter;

=pod
Donnés totales (masse et bras de levier total) : cf ListeMatos::TotalItem
=cut

sub init {
	$treestore = shift;
}

sub new {
	my ($helico, $controllerCarburant, $controllerTotal, $categories) = @_;
	#efface toutes les données de la liste
	$treestore->clear;

	my $helico_iter = $treestore->append(undef);
	_set_values($helico_iter, $helico->get_bras_masse, $helico->get_nom, FONT_NORMAL);
	#_ajoute_item($controllerCarburant, undef);	
	
	my $item = $controllerCarburant->get_model;
	my $nom	 = $item->get_nom	;
	my $masse = $item->get_masse;
	my $bras = $item->get_bras ;	
	
	#Ajout dans le GtkTreeStore
	my $iter = $treestore->append (undef);	
	_set_values($iter, $bras, $masse, $nom, FONT_NORMAL);

	$controllerCarburant->set_update_ListeMatos_func(sub {_update_item($iter, $item, undef); });
	
	
	foreach my $categorie (@$categories) {
		my $cat_iter = $treestore->append(undef);
		_set_values($cat_iter, 0, 0, $categorie->get_nom, FONT_GRAS);
		$categorie->set_update_ListeMatos_func(sub {_update_iter($cat_iter, $categorie->get_model->get_bras_masse); });

		my $items = $categorie->get_items();
		foreach my $controllerItem (@$items) {
			my $func = sub {
				_ajoute_item($controllerItem, $cat_iter);
			};
			$controllerItem->set_ajoute_ListeMatos_func($func);
		}

	}

	$lastiter = $treestore->append(undef);
	
	$controllerTotal->set_update_ListeMatos_func(sub {_update_iter($lastiter, $controllerTotal->get_model->get_bras_masse); }); 
	
	#mise à jour du ListStore
	_set_values($lastiter, $controllerTotal->get_model->get_bras_masse, 'Total', FONT_GRAS);
}

sub _update_iter {
	my ( $iter, $bras, $masse) = @_;
	_set_values_l($iter, COL_MASSE , $masse, 
		COL_BRAS	, $bras ,
		COL_MOMENT, $masse * $bras);
}

sub _ajoute_item {

	my ($controllerItem, $cat_iter) = @_;
	
	my $item = $controllerItem->get_model;
	my $iter = $treestore->append ($cat_iter);	
	{
		my $nom	 = $item->get_nom	;
		my $masse = $item->get_masse;
		my $bras = $item->get_bras ;	
		
		#Ajout dans le GtkListStore
		_set_values($iter, $bras, $masse, $nom, FONT_NORMAL);
	}

	foreach my $sousitem (@{$item->get_items}) {
	
		my $nom	 = $sousitem->get_nom	;
		my $masse = $sousitem->get_masse;
		my $bras = $sousitem->get_bras ;	
		
		#Ajout dans le GtkListStore
		my $sousiter = $treestore->append ($iter);	
		_set_values($sousiter, $bras, $masse, $nom, FONT_NORMAL);

	}

	#mise à jour de la catégorie (ça n'a rien à faire la certes...)
#	my ($cat_bras, $cat_masse, $cat_bras_l) = $treestore->get($cat_iter, COL_BRAS, COL_MASSE); #, COL_BRAS_L);
#	my ($new_cat_bras, $new_cat_masse) = calcul::Centrage::ajoute_masse($cat_bras, $cat_masse);
#	my ($new_cat_bras_l) = calcul::Centrage::ajoute_masse($cat_bras_l, $cat_masse);
#	_set_values_l($cat_iter, COL_BRAS, $new_cat_bras, COL_MASSE, $new_cat_masse); #, COL_BRAS_L, $new_cat_bras_l);
	
	$controllerItem->set_update_ListeMatos_func(sub {_update_item($iter, $item, $cat_iter); });
	$controllerItem->set_delete_ListeMatos_func(sub {_enleve_item($iter, $item, $cat_iter);});
}

sub _enleve_item {
	my ($iter, $item, $cat_iter) = @_;

	#mise à jour de la catégorie (ça n'a rien à faire la certes...)
#	my ($cat_bras, $cat_masse, $cat_bras_l) = $treestore->get($cat_iter, COL_BRAS, COL_MASSE);#, COL_BRAS_L);
#	my ($new_cat_bras, $new_cat_masse) = calcul::Centrage::enleve_masse($cat_bras, $cat_masse);
#	my ($new_cat_bras_l) = calcul::Centrage::enleve_masse($cat_bras_l, $cat_masse);
#	_set_values_l($cat_iter, COL_BRAS, $new_cat_bras, COL_MASSE, $new_cat_masse) ;#, COL_BRAS_L, $new_cat_bras_l);
	
	$treestore->remove($iter);
}

sub _update_item {
	my ($iter, $item, $cat_iter) = @_;

	_update_iter($iter, $item->get_bras_masse);
	#mise à jour de la catégorie (ça n'a rien à faire la certes...)
#	my ($cat_bras, $cat_masse, $cat_bras_l) = $treestore->get($cat_iter, COL_BRAS, COL_MASSE, COL_BRAS_L);
#	my ($new_cat_bras, $new_cat_masse) = calcul::Centrage::enleve_masse($cat_bras, $cat_masse);
#	my ($new_cat_bras_l) = calcul::Centrage::enleve_masse($cat_bras_l, $cat_masse);
#	_set_values_l($cat_iter, COL_BRAS, $new_cat_bras, COL_MASSE, $new_cat_masse);#, COL_BRAS_L, $new_cat_bras_l);
}

=pod
Ajoute un matériel $item dans la liste.
Elle met à jour automatiquement l'objet total et la ligne total.
Elle utilise également la méthode $item->set_delete_liste_func

Prends en paramètre un objet item implémentant les méthodes suivantes :
$item->get_nom
$item->get_masse
$item->get_bras
$item->set_delete_liste_func ($func) : permet à l'item de supprimer l'item de la liste en appelant la fonction $func.
=cut
sub ajoute {
	my $controllerItem = shift;
	
	my $item = $controllerItem->get_model;
	my $nom	 = $item->get_nom	;
	my $masse = $item->get_masse;
	my $bras	= $item->get_bras ;	
	
	#Ajout dans le GtkListStore
	my $iter = $treestore->insert_before (undef, $lastiter);	
	_set_values($iter, $bras, $masse, $nom, FONT_NORMAL);
	
	$controllerItem->set_update_ListeMatos_func(sub {_update_iter($iter, $item->get_bras_masse); });
	$controllerItem->set_delete_ListeMatos_func(sub {$treestore->remove($iter); });
}



=pod
Synchronise les donnés de la dernière ligne total avec l'objet total
=cut

#Mets à jour la ligne $iter du GtkListStore $treestore
sub _set_values {
	my ($iter, $bras, $masse, $nom, $font) = @_;

	#$font = FONT_NORMAL unless defined($font);
	$treestore->set ($iter, COL_NOM , $nom,
		COL_MASSE, $masse,
		COL_BRAS, $bras,
		COL_MOMENT, $masse * $bras,
		COL_FONT, $font);
}

#Mets à jour la ligne $iter du GtkListStore $treestore (autre syntaxe possible)
sub _set_values_l {
	$treestore->set (@_);
}


#
sub to_array {
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



1;

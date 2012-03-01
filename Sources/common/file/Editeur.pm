package file::Editeur;

use strict;

use LoadDat;

use models::Categorie;
use models::Item;
use models::MainItem;
use calcul::Id;

=pod
Charge la base de données de matos, construit un tableau de catégories d'item
renvoie undef si erreur
=cut
#use constant COL_ID     => 0;
use constant COL_NOM         => 0;
use constant COL_MASSE       => 1;
use constant COL_BRAS        => 2;
use constant COL_BRAS_L      => 3;
use constant COL_IMG         => 4;
use constant COL_EST_PRESENT => 5;
use constant COL_DRAGABLE    => 6;


# sub categories {
  # return shift;
# }

sub load {
	my ($base_filename) = @_;
	my $base = LoadDat::load($base_filename);
	
	if (!$base) {
		GenericWin::erreur_msg("Impossible de charger la liste de materiel de $base_filename : ".LoadDat::get_erreur);
		return undef;
	}
	
	
	my @base_categories = ();
	#my $id = 0; 

	foreach my $obj (@$base) {

		my @tab_item = ();
		my $curitem;

		foreach my $ligne (@{$obj->{contenu}}) {

			my $nom = $ligne->[COL_NOM];
			my $curid = undef;
			my $est_sous_item = substr($nom,0,2) eq '::';

			if ($est_sous_item) {
				$nom = substr($ligne->[COL_NOM],2);
			}
			#else {
				#$curid = $id;
				#$id++;
			#}

			my $item = models::MainItem->new($ligne->[COL_BRAS], $ligne->[COL_MASSE], $nom,
					$ligne->[COL_BRAS_L], $ligne->[COL_IMG], 
					$ligne->[COL_EST_PRESENT], $ligne->[COL_DRAGABLE]);
					#$id);

			if ($est_sous_item) {
				$curitem->add_item($item);
			}
			else {
				$curitem = $item;
				push @tab_item, $curitem;
			}
		}
		
		push @base_categories, models::Categorie->new($obj->{titre}, \@tab_item);
	}
	

	calcul::Id::auto_set_categories(\@base_categories);
	return \@base_categories; #bless(\@base_categories);
}

sub save {
	my ($file, $base) = @_;
	my @tab = map { _cat_to_hash ($_); } @$base;
	LoadDat::save($file, \@tab);
	
}
# use Data::Dumper;
sub _cat_to_hash {
	my $categorie = shift;
	# my $items = $categorie->get_items;
	my @tab_items = ();
	
	my $flatten_func = sub {
		my $mainitem = shift;
		push @tab_items, _item_to_tab($mainitem);
		foreach my $item (@{$mainitem->get_items}) {
			my $tab = _item_to_tab($item);
			$tab->[COL_NOM] = '::'.$tab->[COL_NOM];
			push @tab_items, $tab;
		}
	};
	
	map {$flatten_func->($_);} @{$categorie->get_items};
	
	return { titre => $categorie->get_nom, contenu => \@tab_items};
}



sub _item_to_tab {
	my $item = shift;
	#a accorder avec COL_NOM
	my @tab = ($item->get_nom, $item->get_masse, $item->get_bras, $item->get_bras_l, $item->get_img, 
		$item->is_present_pesee, $item->is_dragable);
	
	#my $bras_l = $item->get_bras_l;	
	#if (defined($bras_l)) {
		#push @tab, $bras_l;
		#my $img = $item->get_img;
		#push @tab, $img if (defined($img));
	#}
	
	return \@tab;
}


1;

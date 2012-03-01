package file::Helico;

use strict;

use LoadDat;
use GenericWin;
use models::Helico;

=pod
Charge le fichier contenant les infos sur l'hélico :
masse, bras, image, coordonnées constructeurs à respecter
Renvoie un InterfaceController::helico ou undef si impossible de lire le fichier

load($filename, $nom_helico) : $filename nom du fichier à lire
  $nom_helico nom de l'hélico (pour construire l'objet models::Helico)
=cut

#Numéro de la section helico apparaissant dans le fichier (caractéristiques de l'hélico)
use constant SECTION_HELICO     => 0;
#Numéro de la section graphcoord apparaissant dans le fichier 
use constant SECTION_GRAPHCOORD => 1;
use constant SECTION_TAILLEGRAPHE =>2;
use constant SECTION_CONFIG_BASE => 3;
use constant SECTION_PESEE => 4;

use constant SECTION_HELICO_NAME     => 'helico';
use constant SECTION_GRAPHCOORD_NAME => 'graphcoord';
use constant SECTION_TAILLEGRAPHE_NAME =>'taillegraph';
use constant SECTION_CONFIG_BASE_NAME => 'configbase';
use constant SECTION_PESEE_NAME => 'pesee';

use constant COL_MASSE => 0;
use constant COL_BRAS  => 1;
use constant COL_IMG   => 2;

# a accorder avec _save_config
use constant COL_CONFIG_NOM         => 0;
use constant COL_CONFIG_MASSE       => 1;
use constant COL_CONFIG_BRAS        => 2;
use constant COL_CONFIG_PESEE       => 3;
#use constant COL_CONFIG_BRAS_L      => 3;

#usage : load ($filename, $nom_de_l'helico)
sub load {
	my ($base_filename, $helico_nom) = @_;
	my $base = LoadDat::load($base_filename);

	if (!$base) {
		GenericWin::erreur_msg("Impossible de charger le fichier de configuration de $helico_nom : ".LoadDat::get_erreur);
		return undef;
	}

	#Il n'y a que 3 lignes : celle concernant l'hélico en question (helico.dat) et l'icone associé
	#la 3e : masse et bras à vide
	my $ligne = $base->[SECTION_HELICO]->{contenu}->[0];
	my $icone = $base->[SECTION_HELICO]->{contenu}->[1][0];

	my ($masse, $bras, $img) = ($ligne->[COL_MASSE], $ligne->[COL_BRAS], $ligne->[COL_IMG]);

	#for fun
	my @masse_bras_vide = (50, 50);
	if ($base->[SECTION_HELICO]->{contenu}->[2]) {
		@masse_bras_vide = @{$base->[SECTION_HELICO]->{contenu}->[2]};
	}

	#on doit tout avoir, et une masse non nulle (car sinon division par 0 dans ListMatos)
	if (!defined($img) || !$masse) {
		GenericWin::erreur_msg("Erreur de lecture des caractéristiques de $helico_nom : ".join ($ligne));
		return undef;
	}

	my $tab = _load_graphcoord_section($base->[SECTION_GRAPHCOORD]);
	#On doit avoir au moins un point
	# if (scalar(@$tab) == 0) {
	# GenericWin::erreur_msg("Erreur de lecture du fichier de configuration de $helico_nom : pas de coordonnées constructeurs");
	# }
	my $echbras = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[0][0];
	my $echpix = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[0][1];
	my $schemaratiox = $echpix/$echbras;
	$echbras = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[1][0];
	$echpix = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[1][1];
	my $schemaratioy = $echpix/$echbras;
	my $schemaoffsetx = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[2][0];
	my $schemaoffsety = $base->[SECTION_TAILLEGRAPHE]->{contenu}->[3][0];

	my ($masse_pesee, $bras_pesee) = _load_pesee_section($base->[SECTION_PESEE]);

	my $config_base = _load_configbase_section($base->[SECTION_CONFIG_BASE]);
	#on ajoute la config de base à la masse de l'hélico
	#map { ($bras, $masse) = calcul::Centrage::ajoute_masse($bras, $masse, $_->get_bras_masse);} @$config_base;

	return models::Helico->new($bras, $masse, $helico_nom, 0, $img, $icone,$tab,
		$schemaratiox,$schemaratioy,$schemaoffsetx,$schemaoffsety,
		$masse_pesee, $bras_pesee, @masse_bras_vide, $config_base);
}

#lit le tableau de points de la section [graphcoord]
sub _load_graphcoord_section {
	my ($section) = @_;

	my @tab_points = ();

	foreach my $ligne (@{$section->{contenu}}) {
		push @tab_points, $ligne;
	}

	return \@tab_points;
}

sub _load_pesee_section {
	my ($section) = @_;
	return (0, 0) unless $section;
	return ($section->{contenu}->[0][0], $section->{contenu}->[0][1]);
}

sub _load_configbase_section {
	my ($section) = @_;

	my @tab_item = ();
	my $curitem;

	foreach my $ligne (@{$section->{contenu}}) {

		my $nom = $ligne->[COL_CONFIG_NOM];
		my $est_sous_item = substr($nom,0,2) eq '::';

		if ($est_sous_item) {
			$nom = substr($ligne->[COL_CONFIG_NOM],2);
		}

		my $item = models::MainItem->new($ligne->[COL_CONFIG_BRAS], $ligne->[COL_CONFIG_MASSE], $nom,
			undef, undef, $ligne->[COL_CONFIG_PESEE]);
			#$bras_l, $img, $est_present_pesee, $dragable, $id);
				#$ligne->[COL_CONFIG_BRAS_L]);

		if ($est_sous_item) {
			$curitem->add_item($item);
		}
		else {
			$curitem = $item;
			push @tab_item, $curitem;
		}
	}

	return \@tab_item;
}

sub save {
	my ($base_filename, $helico) = @_;
	my @base = ();



	$base[SECTION_HELICO] = {titre => SECTION_HELICO_NAME,
		contenu => [[$helico->get_masse, $helico->get_bras, $helico->get_img],
			[$helico->get_icone],
			[$helico->get_masse_vide, $helico->get_bras_vide]]};

	
	$base[SECTION_GRAPHCOORD] = {titre => SECTION_GRAPHCOORD_NAME,
		contenu => $helico->get_limite_centrage_coords};
	
	my $ratiox = $helico->get_schemaratiox;
	my $ratioy = $helico->get_schemaratioy;

	$base[SECTION_TAILLEGRAPHE] = {titre => SECTION_TAILLEGRAPHE_NAME,
		contenu => [[1, $helico->get_schemaratiox],
			[1, $helico->get_schemaratioy],
			[$helico->get_schemaoffsetpixx/$ratiox],
			[$helico->get_schemaoffsetpixy/$ratioy]]};

	$base[SECTION_CONFIG_BASE] = {titre => SECTION_CONFIG_BASE_NAME,
		contenu => _save_configbase($helico->get_config_base)};

	$base[SECTION_PESEE] = {titre => SECTION_PESEE_NAME,
		contenu => [[$helico->get_masse_pesee, $helico->get_bras_pesee]]};

	LoadDat::save($base_filename, \@base);
}

sub _save_configbase {
	my $configbase = shift;
	my @tab_items = ();
	
	my $flatten_func = sub {
		my $mainitem = shift;
		push @tab_items, _item_to_tab($mainitem);
		foreach my $item (@{$mainitem->get_items}) {
			my $tab = _item_to_tab($item);
			$tab->[COL_CONFIG_NOM] = '::'.$tab->[COL_CONFIG_NOM];
			push @tab_items, $tab;
		}
	};
	
	map {$flatten_func->($_);} @$configbase;
	
	return \@tab_items;
}



sub _item_to_tab {
	my $item = shift;
	my @tab = ($item->get_nom, $item->get_masse, $item->get_bras, $item->is_present_pesee);
	return \@tab;
}

1;

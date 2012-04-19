package mainWin::Controller;
#TODO: afficher les messages d'erreur seulement ici (mettre des fonctions erreur dans chaque module)
#TODO: fusion set_carb et calc_carb
#TODO: changer le nom de $liste_carburant (ca ne correspond pas)

=pod
S'occupe de charger les base de données, coordonne SchemaHelico, Onglets, mainWin::widgets::ListeMatos, GrapheCentrage contient la base de données.
Le principe : aucun des modules SchemaHelico (schéma de l'hélico), Onglets (matos équippable),
mainWin::widgets::ListeMatos(matos équippé) ou GrapheCentrage (graphique masse fct bras) ne font explicitement référence à ce module. Stylé non ?

file::Base : charge la base de donnés des items équippables sur tel hélico
file::Helico : charge les infos concernant tel hélico
file::Config : charge la liste des hélicos aussi que d'autre informations générales

models::Categorie : classe Categorie, représente une catégorie de matériel (-> onglet)
models::Item : clase Item, représente un matériel, accessoire (->bouton)
models::Helico : clase Helico, représente un hélico

Le fichier config.dat contient la liste des noms d'hélicos associés à leurs sous-dossiers (EC135\ par exemple)
Le fichier EC135\helico.dat contient la liste des coordonnées constructeurs imposés + masse et bras de l'hélico
Le fichier EC135\base.dat contient la liste des matériel équippable sur cet hélicos regroupé par catégorie

Le dossier img\ contient toutes les images utilisés par le programme


init($schemahelico, $notebook, $liststore, $area) : initialise tout
	$schemahelico : GtkDrawingArea pris en charge par le module SchemaHelico
	$notebook : GtkNotebook pris en charge par le module Onglets
	$liststore : GtkListStore pris en charge par le module ListeStore
	$area : GtkDrawingArea pris en charge par le module GrapheCentrage

export_ods : exporte la liste du matériel équippé au format .ods (lance openoffice)
get_mot_de_passe : renvoie le mot de passe admin lu	dans CONFIG_FILE
helicos : renvoie la liste des hélicos associés à leur dossier ($helicos)
=cut

use strict;
use utf8;

use GenericWin;
use calcul::CentrageCheck;
use calcul::Centrage;
use calcul::Total;
use calcul::Carburant;
use mainWin::widgets::SchemaHelico;
use mainWin::widgets::Onglets;
use mainWin::widgets::ListeMatos;
use mainWin::widgets::GrapheCentrage;
use mainWin::widgets::Carburant;
use mainWin::Controller::Item;
use mainWin::Controller::Categorie;
use file::Config;
use file::Helico;
use file::Carburant;
use file::Profils;

use Arborescence;
#pour exporter au format ods
use Ods;
#pour gérer les répertoires
use File::Spec;
use Cwd;

#use constants::File;
use constant EDITEUR_FILE => 'editeur.dat';
use constant HELICO_FILE => 'helico.dat';
use constant CONFIG_FILE => 'config.dat';
use constant CARBURANT_FILE => 'carburant.dat';
use constant PROFILS_FILE => 'profils.dat';

use constant DEFAULTHELI => 0;
#nom du fichier .ods créé par export_ods
use constant ODS_FILE => 'fichier.ods';
use constant ODS_DIR	=> File::Spec->catdir('utils','Ods');
use constant IMG_DIR => 'img';
use constant HELICOS_DIR => 'helicos';
use constant CENTRAGEKO_IMG_NAME => 'centrageko.png';
#Reference vers des Tableaux de { nom => , dossier =>	}
my ($helicos,$typehelicos);
#Le mot de passe
my ($mdpadmin,$mdpsuperadmin);

my $centrageCheck;
my $liste_carburant;
my $controllerTotal;
my $controllerCarburant;
my @carb_points;
#Le répertoire de base
my $base_dir = main::get_base_dir();
my $centbuf;
my $iconebuf;
my $item_helico;
my $helico;
my $curheliname;
use Data::Dumper;
sub init {
	my ($schemahelico, $notebook, $liststore, $area, $centbuftrans, $listehelico,$listetypehelico, $carbspinkg, $carbspinli, $carbprogress,$iconebuftrans,$curhelinametrans) = @_;

	#Initialisation de gauche à droite, de haut en bas.
	#Initialise le schéma de l'hélico
	mainWin::widgets::SchemaHelico::init ($schemahelico, File::Spec->catdir($base_dir,IMG_DIR));
	#Initialise les onglets de matos
	mainWin::widgets::Onglets::init ($notebook);
	mainWin::widgets::Carburant::init($carbspinkg,$carbspinli, $carbprogress);
	#Initialise la liste de matériel équippé (notamment la ligne totale)
	mainWin::widgets::ListeMatos::init ($liststore);
	#initialisation du graphe de centrage et masse
	mainWin::widgets::GrapheCentrage::init ($area);

	#initialisation du buffer
	$centbuf = $centbuftrans;
	$iconebuf = $iconebuftrans;
	$centrageCheck = calcul::CentrageCheck->new;
	$helicos = get_helicos();
	$typehelicos = Config::KeyFileManage::get_typehelicos();
	$mdpadmin = Config::KeyFileManage::get_mdp_admin();
	$mdpsuperadmin = Config::KeyFileManage::get_mdp_super();
	$curheliname = $curhelinametrans;
	ManageList::init_type($listetypehelico,$typehelicos);
	ManageList::init_heli($listehelico,$helicos);
	#si erreur (le message a déjà été affiché)
	if (!$mdpadmin) {
		exit(1);
	}
	if (scalar(@$helicos) == 0) {
		GenericWin::erreur_msg([['erreurs','no_helico']]);
	}
	else {
		set_helico($helicos->[0]);

	}

}

#supposant qu'on est déjà dans le bon répertoire
sub _export_ods {
	#fichier temporaire
	my $file = File::Spec->catfile(File::Spec->tmpdir, ODS_FILE);
	# my $file = File::Spec->catfile($base_dir, ODS_FILE);

	#exportation
	if (!Ods::export(mainWin::widgets::ListeMatos::to_array, $file)) {
		GenericWin::erreur_msg([['erreur','ods_export']],Ods::get_erreur);
		return 0;
	};

	#lancement d'openoffice
	my $cmd;
	if ($^O eq 'linux') {
		$cmd = "oocalc $file";
	}
	else {
		$cmd = $file;
	}

	if (system($cmd)) {
		GenericWin::erreur_msg([['erreurs','ouverture']], $file.$?);
		return 0;
	}
	return 1;
}

sub export_ods {
	my $dir = cwd;#on se place dans le bon dossier
	if (!chdir (File::Spec->catdir($base_dir, ODS_DIR))) {
		GenericWin::erreur_msg([['erreurs','ch_dir']],ODS_DIR.' : '.$!);
		return 0;
	}
	my $ret = _export_ods();
	#on se remet là où on était
	chdir $dir;
	return $ret;
}

sub set_limite_centrage_coords {
	my $coords = shift;
	mainWin::widgets::GrapheCentrage::set_limite_centrage_coords($coords);
	$centrageCheck->set_limite_centrage_coords($coords);
}

#Choisis l'hélico et se place dans le bon répertoire
sub set_helico {
	#un élément de $helicos
	$item_helico = shift;
	my $heli_dos = $item_helico->{nom};
	my $type_heli = $item_helico->{type};
	my $type_heli_dos = Config::KeyFileManage::get_dossier_by_type($type_heli);
#	my $dir = File::Spec->catdir($base_dir, HELICOS_DIR, $type_heli_dos,$heli_dos);
	my $dir = Arborescence::get_helico_dir($type_heli_dos, $heli_dos);
	administration::Controller::set_helidir_current($dir,$base_dir);

	#on se place dans le bon répertoire
	if (!chdir ($dir)) {
		GenericWin::erreur_msg([['erreurs','ch_dir']],$dir.':'.$!);
		#return false
		return 0;
	}
	my $nom_complet = $type_heli.' - '.$heli_dos;
	# my $helico_nom = shift;
	$helico = file::Helico::load(HELICO_FILE, $nom_complet);

	if (!$helico) {
		#le message d'erreur est déjà pris en compte par Helico::load
		#return false
		return 0;
	}

	$liste_carburant = file::Carburant::load(CARBURANT_FILE);

	if (!$liste_carburant) {
		GenericWin::erreur_msg (file::Carburant::get_erreur());
	}
	#set de l'icone de l'helico
	$iconebuf->clear();
	$iconebuf->set_from_file(File::Spec->catfile($base_dir,IMG_DIR,$helico->get_icone()));
	$curheliname->set_text($nom_complet);

	$controllerTotal = mainWin::Controller::Item->new(calcul::Total->new(0, 0));
	$controllerCarburant = mainWin::Controller::Item->new(models::Item->new(0, 0, 'Carburant'));
	@carb_points = ();
	get_total()->add_item($helico);

	#Construit la base de donnés des catégories à partir du fichier $base_file, liste vide si erreur

	my $base = file::Editeur::load(EDITEUR_FILE) || [];
	my @categories = map { mainWin::Controller::Categorie->new($_); } @$base;

	my $profils = file::Profils::load(PROFILS_FILE) || [];

	#Construit le schéma de l'hélico
	mainWin::widgets::SchemaHelico::new($helico);

	#construit les onglets sur le GtkNotebook $notebook à partir du tableau des catégories chargées
	mainWin::widgets::Onglets::new(\@categories, $profils);
	#Initialise la liste de matériel équippé (notamment la ligne totale)
	mainWin::widgets::ListeMatos::new($helico, $controllerCarburant, $controllerTotal, \@categories);

	set_limite_centrage_coords($helico->get_limite_centrage_coords);
	mainWin::widgets::Carburant::set_liste_carburant($liste_carburant);
	mainWin::widgets::Carburant::set_carb(0);
	set_carb(0);
	update_interface();
	return 1;
}

#mise à jour du dessin du graphe de centrage
sub update_graphe_centrage {
 # mainWin::widgets::GrapheCentrage::set_total(mainWin::widgets::ListeMatos::total);
	mainWin::widgets::GrapheCentrage::update();
}

sub update_schema_helico {
	mainWin::widgets::SchemaHelico::update;
}

sub set_is_good {
	my $is_good = shift;
	#mainWin::widgets::GrapheCentrage::set_is_good($is_good);

	if($is_good) {
		$centbuf->set_text("le centrage est bon");
	 $iconebuf->set_from_file(File::Spec->catfile($base_dir,IMG_DIR,$helico->get_icone()));
	} else {
		$centbuf->set_text("ATTENTION : centrage hors limites");
		$iconebuf->set_from_file(File::Spec->catfile($base_dir,IMG_DIR,CENTRAGEKO_IMG_NAME));
	}
}

#appelé lorsque $total a changé (ajout ou suppression d'item)
sub update_interface {
	my $total = get_total();
	set_is_good(is_good());

	my @initpoint = calcul::Centrage::enleve_masse($total->get_bras_masse,
		get_carburant()->get_bras_masse);


	my $func = sub {
		my $item = shift;
		my @arr = calcul::Centrage::ajoute_masse(@initpoint, $item->get_bras_masse);
		return \@arr;
	};

	my @points = map {$func->($_)} @carb_points;

	push @points, [$total->get_bras_masse];
	mainWin::widgets::GrapheCentrage::set_points(\@points);

	$controllerTotal->update_ListeMatos;

	update_graphe_centrage();
	update_schema_helico();

}

###############################
# SECTIONS EVENEMNTS
# Appelés depuis les widgets ou par Controller::Item
# on_Widget_evenement
##############################

#DEPRECATED
sub ajoute_matos {
	on_Onglets_button_activate(@_);
}

sub on_Onglets_button_activate {
	my $controllerItem = shift;
	#my $controllerCategorie = $controllerItem->get_categorie;

	get_total()->add_item($controllerItem->get_model);
	#$controllerCategorie->get_model->add_item($controllerItem->get_model);

	#$controllerCategorie->update_ListeMatos;
	$controllerItem->ajoute_ListeMatos;

	mainWin::widgets::SchemaHelico::ajoute($controllerItem);

	update_interface();

}

#DEPRECATED
sub enleve_matos {
	on_Onglets_button_desactivate(@_);
}

sub on_Onglets_button_desactivate {
	my $controllerItem = shift;

	#my $controllerCategorie = $controllerItem->get_categorie;

	get_total()->remove_item($controllerItem->get_model);
	#my $cat_model = $controllerCategorie->get_model();

	#$cat_model->remove_item($controllerItem->get_model);
	#pb d'arrondi
	#$cat_model->set_bras(0) unless (int ($cat_model->get_masse));
	#$controllerCategorie->update_ListeMatos;
	$controllerItem->delete_SchemaHelico();
	$controllerItem->delete_ListeMatos();
	update_interface();
}

#DEPRECATED
sub set_carb_max {
	on_Carburant_carbmax_click(@_);
}

sub on_Carburant_carbmax_click {
	my $total = get_total();
	#$total->remove_item(get_carburant());

	#pb : redondant avec set_carb
	my $item = calcul::Carburant::max_carburant($centrageCheck, $liste_carburant,
		calcul::Centrage::enleve_masse($total->get_bras_masse, get_carburant()->get_bras_masse)) ;
	my $carbmax = $item->get_masse;
	#my $ratio = $carbmax / $liste_carburant->maxmasse;


	#get_carburant()->set_bras_masse($item->get_bras_masse);
	#$total->add_item($item);

	#$controllerCarburant->update_ListeMatos;
	# update_interface();
	mainWin::widgets::Carburant::set_carb($carbmax) ;

	set_carb($carbmax);
}

#DEPRECATED
sub set_carb {
	on_Carburant_change_carb(@_);
}

sub on_Carburant_change_carb {
	my $masse = shift;

	@carb_points = calcul::Carburant::get_plus_leger($liste_carburant, $masse);
#	@carb_points = ($liste_carburant->get_items->[0], $liste_carburant->get_items->[1]);
	my $bras = calcul::Carburant::get_bras_interpol($carb_points[-2], $carb_points[-1], $masse);
	pop @carb_points;

	my $total = get_total();
	$total->remove_item(get_carburant());

	get_carburant()->set_bras_masse($bras, $masse);
	$controllerCarburant->update_ListeMatos;

	$total->add_item(get_carburant());
	update_interface();
}


sub get_total {
	return $controllerTotal->get_model;
}

#DEPRECATED
#sub update_total {
#	on_SchemaHelico_drag(@_);
#}

sub on_SchemaHelico_drag {
	my ($controllerItem, $bras, $bras_l) = @_;
	my $item = $controllerItem->get_model;
	my $total = get_total;

	#my $controllerCategorie = $controllerItem->get_categorie;
	#my $model = $controllerCategorie->get_model;

	#$model->remove_item($item);
	$total->remove_item($item);

	$item->set_bras($bras);
	$item->set_bras_l($bras_l);

	$total->add_item($item);
	#$model->add_item($item);

	#$controllerCategorie->update_ListeMatos;
	$controllerItem->update_ListeMatos;
	$controllerItem->update_Onglets;

	update_interface();
}

sub get_carburant {
	return $controllerCarburant->get_model;
}

sub is_good {
	return $centrageCheck->is_good(get_total()->get_bras_masse);
}



sub get_mot_de_passe {
	return ($mdpadmin,$mdpsuperadmin);
}

sub get_helicos {
	return Config::KeyFileManage::get_helicos();
}

sub raz {
	set_helico($item_helico) if (GenericWin::ouinon([['messages','raz'],['messages','irreversible']]));

}

sub export_graphe_to_pdf {
  my $path = GenericWin::filechooser([['titres','exporter']],'save','pdf','graphe.pdf');
  mainWin::widgets::GrapheCentrage::export_pdf($path);
}
1;

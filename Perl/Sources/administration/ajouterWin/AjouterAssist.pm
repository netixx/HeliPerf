package administration::ajouterWin::AjouterAssist;

use strict;
use utf8;
use File::Spec;
use IO::Uncompress::Unzip qw(unzip $UnzipError);


use constant PAGE_EDIT_BDD		=> 3;
use constant PAGE_PRESENT_PESEE	=> 4;
use constant PAGE_CONFIG_BASE	=> 5;

use Data::Dumper;
use administration::ajouterWin::AjouterAssistPage;
use administration::ajouterWin::widgets::OngletsMatos;


my $listetypeheli;
my $combo;
my $entry;
my $oAssWin;
my $confirm_page;
my $nom_page;
my $resume_page;
my $text;
my $import = 0;
my $oMasse;
my $oCentrage;
my $oNoteBook;
my $oHelico;

sub assist {
	$oNoteBook = administration::ajouterWin::widgets::OngletsMatos->new();
	$listetypeheli = ManageList::construct_type();#construction de la liste des types d'hélico
	administration::ajouterWin::AjouterAssistPage::init($listetypeheli, $oNoteBook);
	$oAssWin = Gtk2::Assistant->new();
	#definitiaons des callback fermeture, destruction et annuler
	$oAssWin->signal_connect(close => \&do_close);
	$oAssWin->signal_connect(destroy => \&do_close);
	$oAssWin->signal_connect(cancel => \&do_close);
	$oAssWin->signal_connect(prepare => \&prepare_next);

	#ajout de l'icone de la fenetre
	my $pathimg = File::Spec->catfile(main::get_base_dir(),'img','insigne_fag_transparence.png');
	$oAssWin->set_icon_from_file($pathimg);
	#fenetre modale
	$oAssWin->set_modal(1);

	$oAssWin->set_title("Ajouter un hélicoptère");#titre
	#premiere page d'introduction
	my $intro_page = administration::ajouterWin::AjouterAssistPage::intro_page();
	$oAssWin->append_page($intro_page);
	$oAssWin->set_page_title($intro_page,"Ajouter un hélicoptère");
	$oAssWin->set_page_type($intro_page,'intro');
	$oAssWin->set_page_complete($intro_page,1);

	#deuxième page choix du type et du nom
	my @tab = administration::ajouterWin::AjouterAssistPage::nom_page();
	$nom_page = $tab[0];#recuperation de la page entiere
	$entry = $tab[2];#recuperation de l'entrée texte
	$combo = $tab[1];#recuperation du combobox

	$oAssWin->append_page($nom_page);
	$oAssWin->set_page_title($nom_page,"Type et numéro de l'hélicoptère");
	$oAssWin->set_page_type($nom_page,'content');
	$oAssWin->set_page_complete($nom_page, 0);

	#Troisième page saisie de la masse et du centrage
	my @tab_centrage = administration::ajouterWin::AjouterAssistPage::masse_et_centrage();
	my $masse_centrage_page = $tab_centrage[0];#recuperation de la page entiere
	$oMasse = $tab_centrage[2];#recuperation de l'entrée texte
	$oCentrage = $tab[1];#recuperation du combobox

	$oAssWin->append_page($masse_centrage_page);
	$oAssWin->set_page_title($masse_centrage_page,"Masse et centrage");
	$oAssWin->set_page_type($masse_centrage_page,'content');
	$oAssWin->set_page_complete($masse_centrage_page, 0);

	#4ieme page-> étition de la base de donnée
	my $oEditBddTemplate = administration::ajouterWin::AjouterAssistPage::layout_adaptation_bdd_template();
	$oAssWin->append_page($oEditBddTemplate);
	$oAssWin->set_page_title($oEditBddTemplate,"Édition de la base de donnée");
	$oAssWin->set_page_type($oEditBddTemplate,'content');
	$oAssWin->set_page_complete($oEditBddTemplate, 1);

	#5ieme page -> choix des equipement présents en pesée
	my $oPresentPesee = administration::ajouterWin::AjouterAssistPage::layout_choix_present_pesee();
	$oAssWin->append_page($oPresentPesee);
	$oAssWin->set_page_title($oPresentPesee,"Choix des équipement présents en pesée");
	$oAssWin->set_page_type($oPresentPesee,'content');
	$oAssWin->set_page_complete($oPresentPesee, 1);

	#6ieme page -> choix de la configuration de base
	my $oConfigBase = administration::ajouterWin::AjouterAssistPage::layout_choix_config_base();
	$oAssWin->append_page($oConfigBase);
	$oAssWin->set_page_title($oConfigBase,"Choix de la configuration de base");
	$oAssWin->set_page_type($oConfigBase,'content');
	$oAssWin->set_page_complete($oConfigBase, 1);

	#page de confirmation
	$confirm_page = administration::ajouterWin::AjouterAssistPage::confirm_page();
	$oAssWin->append_page($confirm_page);
	$oAssWin->set_page_title($confirm_page,"Confirmation");
	$oAssWin->set_page_type($confirm_page,'confirm');#
	$oAssWin->set_page_complete($confirm_page, 1);

	#page de résumé
	$resume_page = administration::ajouterWin::AjouterAssistPage::resume_page();
	$oAssWin->append_page($resume_page);
	$oAssWin->set_page_title($resume_page,"Résumé");
	$oAssWin->set_page_type($resume_page,'summary');#resumé des actions effectuées
	$oAssWin->set_page_complete($resume_page, 0);

	administration::ajouterWin::AjouterAssistPage::init_assistant($oAssWin);
	$oAssWin->show_all();
}

#marche
sub import_assist_prepare {
	my $path = shift;#on recupere le path du filechooser
	$import = 1;
	my $heli = administration::importWin::Import::scan($path,0);#on recupere le type et le nom
	if (defined($heli)) {
	fill_nom_et_type($heli);#on envoie tout à nom et type
	} else {
	return;
	}
}

##marche
#sub fill_nom_et_type {
#	my $heli = $_[0];
#	$entry->set_text($heli->{nom});
#	$heli->{type} = Config::KeyFileManage::get_type_by_dossier($heli->{dossier});
#	my $found = 0;
#	$listetypeheli->foreach(sub {
#			my $iter = $_[2];
#			my $helil = ($listetypeheli->get($iter,ManageList::COL_LABEL))[0];#on recupere le libelle de l'item
#			#$heli =~ s/\s//g;#suppression des espaces->autre option possible
#			if ( $helil eq $heli->{type} ) {
#			#my $str = $listetypeheli->get_path($iter)->to_string();
#			#my @tab = split(/:/,$str);
#			$listetypeheli->set($iter,ManageList::COL_ACTIVE,1);#on le met actif
#			$found = 1;
#			#$combo->set_active($tab[0]);
#			gestion_display_combobox();#afficher le bon hélico dans le combobox
#			return 1;
#			}
#	});
#	if ($found) {
#	return 1;
#	} else {
#	$combo->set_active(-1);
#	return 0;
#	}
#}


my ($helitype,$heliname);
#fonction pas appelée au bon moment
sub confirm_fill {
	if ($oAssWin->get_page_complete($nom_page)) {#si la page nom est dument remplie
	$heliname = $text;
	$helitype = get_active_label();
	if (defined($helitype) && $heliname ne '') {
		$confirm_page->set_text("\tType l'hélicoptère : $helitype\n\tNom de l'hélicoptère : $heliname\n");
		$oAssWin->set_page_complete($confirm_page,1);
		resume_fill();
		$oAssWin->signal_connect(apply	 => \&create_heli);
		return 1;
	} else {
		$confirm_page->set_text("Erreur lors de la création");
		return 0;
	}
	} else {
	return 0;#la page n'était pas complete
	}
}

#rempli la page de resumé
sub resume_fill {
	my $heli = get_type_and_heli();
	#$oAssWin->signal_connect(apply	 => \&do_close);
	$resume_page->set_text("\tL'hélicoptère $heli->{nom}, de type $heli->{type} à été ajouté.\n Veuillez redemarrer l'application pour que les changements prennent effet.\n");
}


#recupere le label de l'hélico choisi
sub get_active_label {
 #la page nom est complete
 my $typeheli = undef;
	$listetypeheli->foreach(sub {
		my $iter = $_[2];
		my $isactive = ($listetypeheli->get($iter,ManageList::COL_ACTIVE))[0];#on repere l'hélico actif
		if ($isactive) {
			$typeheli = $listetypeheli->get($iter,ManageList::COL_LABEL);
			return 1;
		}
	});
	return $typeheli;
}

#affiche le choix de l'utilisateur a choisi
sub gestion_display_combobox {
	my $found = 0;
	$listetypeheli->foreach(sub {
		my $iter = $_[2];
		my $isactive = ($listetypeheli->get($iter,ManageList::COL_ACTIVE))[0];
		if ($isactive) {
			$combo->set_active_iter($iter);
			$found = 1;
			return 1;
		}
	});
	if($found) {
		return 1;
	} else {
		$combo->set_active(-1);
		return 0;
	}
}

#ecrit dans la liste l'hélico choisi
sub gestion_write_combobox {
	#on remet tout à zéro
	ManageList::reset_type();
	my $id = $combo->get_active();
	#on active juste le bon
	if ($id != -1) {
	$listetypeheli->set($listetypeheli->iter_nth_child(undef,$id),ManageList::COL_ACTIVE,1);
	valid_entry();
	return 1;
	} else {
	$oAssWin->set_page_complete($nom_page,0);
	return 0;#aucun id actif
	}
	gestion_display_combobox();###########test#################
}

#verifie que l'entrée est valide (nom et type)
sub valid_entry {
	$text = $entry->get_text();
	if($text =~ /^\d+$/ && $combo->get_active() != -1) {
		activer_page_courante();
		confirm_fill();
		return 1;
	} else {
		desactiver_page_courante();
		return 0;
	}
}

#verfication des nombres entrés
sub valid_nombre {
	my $oEntree = shift;
	my $nEntree = $oEntree->get_value();
	if ($nEntree > 0) {
		activer_page_courante();
		return 1;
	} else {
		desactiver_page_courante();
		return 0;
	}

}

sub get_type_and_heli {
	if ($oAssWin->get_page_complete($confirm_page)) {
		return {type => $helitype, nom => $heliname};
	}
}

my $once = 0;
#TODO: remplir l'erreur + trouver mieux que once
sub create_heli {
	if (!$oAssWin->get_page_complete($resume_page) && $once == 0) {
			my $base_dir = main::get_base_dir();
			my $heli = get_type_and_heli();
			my $heli_type_dos = Config::KeyFileManage::get_dossier_by_type($heli->{type});
			my $dir = File::Spec->catdir($base_dir,'helicos',$heli_type_dos,$heli->{nom});
		if (mkdir $dir) {
			$once = 1;
		} else {
			if ($! eq 'Le fichier existe') {
			warn "Attention helico deja entregistré";
			} else {
			GenericWin::erreur_end([['erreurs','create_dir']], $dir.$!);
			}
		}
		my $typeheli = $heli->{type};#sauvegarde du type
		$heli->{dossier} = $heli_type_dos;#on remplace pour l'extraction
		if (!$import){
			$heli->{generic} = 1;
		}
		if(import_assist($heli)) {
			$heli->{type} = $typeheli;#on remet le vrai type
			Config::KeyFileManage::add_helico($heli);
			$oAssWin->set_page_complete($resume_page,1);
			$once = 1;
			$oAssWin->signal_connect(apply => \&do_close);
			return next_page();
		} else {
			warn "erreur\n";
			return 0;
		}
	}
}



sub do_close {
	shift->destroy();
}

sub next_page {
	$oAssWin->set_current_page($oAssWin->get_current_page()+1);
}

sub prepare_next {
	my $oAssWin = shift;
	my $nPage = $oAssWin->get_current_page();
	if ($nPage == PAGE_EDIT_BDD) {
		administration::ajouterWin::AjouterAssistPage::chargement_type_helico($combo->get_active_iter());
		$oAssWin->resize(800, 600);
	}
	#elsif ($nPage == PAGE_PRESENT_PESEE) {
	#	administration::ajouterWin::AjouterAssistPage::choix_present_pesee();
	#} elsif ($nPage == PAGE_CONFIG_BASE) {
	#	administration::ajouterWin::AjouterAssistPage::choix_config_base();
	#}
}

sub activer_page_courante {
	gestion_activation_page_courante(1);
}

sub desactiver_page_courante {
	gestion_activation_page_courante(0);
}

sub gestion_activation_page_courante {
	$oAssWin->set_page_complete($oAssWin->get_nth_page($oAssWin->get_current_page()), shift);
}

1;

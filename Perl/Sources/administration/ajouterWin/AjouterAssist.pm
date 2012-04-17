package administration::ajouterWin::AjouterAssist;

use strict;
use utf8;
use File::Spec;
use IO::Uncompress::Unzip qw(unzip $UnzipError);

use administration::ajouterWin::AjouterAssistPage;

my $listetypeheli;
my $combo;
my $entry;
my $asswin;
my $confirm_page;
my $nom_page;
my $resume_page;
my $text;
my $import = 0;

sub assist {
  $listetypeheli = ManageList::construct_type();#construction de la liste des types d'hélico
  administration::ajouterWin::AjouterAssistPage::init(\$listetypeheli);
  $asswin = Gtk2::Assistant->new();

  $asswin->signal_connect(close => \&do_close);#definitiaons des callback fermeture, destruction et annuler
  $asswin->signal_connect(destroy => \&do_close);
  $asswin->signal_connect(cancel => \&do_close);

  #ajout de l'icone de la fenetre
  my $pathimg = File::Spec->catfile(main::get_base_dir(),'img','insigne_fag_transparence.png');
  $asswin->set_icon_from_file($pathimg);
  #fenetre modale
  $asswin->set_modal(1);

  $asswin->set_title("Ajouter un hélicoptère");#titre

  my $intro_page = administration::ajouterWin::AjouterAssistPage::intro_page();
  $asswin->append_page($intro_page);
  $asswin->set_page_title($intro_page,"Ajouter un hélicoptère");
  $asswin->set_page_type($intro_page,'intro');
  $asswin->set_page_complete($intro_page,1);
  #premiere page de l'assistant
  my $import_page = administration::ajouterWin::AjouterAssistPage::import_page();#appel de importe
  $asswin->append_page($import_page);#ajout de la page
  $asswin->set_page_title($import_page,"Importer");#definition du titre de la page (encadré)
  $asswin->set_page_type($import_page,'content');#type de la page (contenu => basique)
  $asswin->set_page_complete($import_page,1);#la page est prete ('suivant' est activé)
  #deuxième page ->idem
  my @tab = administration::ajouterWin::AjouterAssistPage::nom_page();
  $nom_page = $tab[0];#recuperation de la page entiere
  $entry = $tab[2];#recuperation de l'entrée texte
  $combo = $tab[1];#recuperation du combobox

  $asswin->append_page($nom_page);
  $asswin->set_page_title($nom_page,"Type et numéro de l'hélicoptère");
  $asswin->set_page_type($nom_page,'content');
  $asswin->set_page_complete($nom_page,0);


  
  #
  ##troisième page
  #$confirm_page = administration::ajouterWin::AjouterAssistPage::confirm_page();
  #$asswin->append_page($confirm_page);
  #$asswin->set_page_title($confirm_page,"Confirmation");
  #$asswin->set_page_type($confirm_page,'confirm');#page de confirmation
  #$asswin->set_page_complete($confirm_page,0);
  #
  ##quatrième page
  #$resume_page = administration::ajouterWin::AjouterAssistPage::resume_page();
  #$asswin->append_page($resume_page);
  #$asswin->set_page_title($resume_page,"Résumé");
  #$asswin->set_page_type($resume_page,'summary');#resumé des actions effectuées
  #$asswin->set_page_complete($resume_page,0);

  $asswin->show_all();
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

#marche
sub fill_nom_et_type {
  my $heli = $_[0];
  $entry->set_text($heli->{nom});
  $heli->{type} = Config::KeyFileManage::get_type_by_dossier($heli->{dossier});
  my $found = 0;
  $listetypeheli->foreach(sub {
		  my $iter = $_[2];
		  my $helil = ($listetypeheli->get($iter,ManageList::COL_LABEL))[0];#on recupere le libelle de l'item
		  #$heli =~ s/\s//g;#suppression des espaces->autre option possible
		  if ( $helil eq $heli->{type} ) {
			#my $str = $listetypeheli->get_path($iter)->to_string();
			#my @tab = split(/:/,$str);
			$listetypeheli->set($iter,ManageList::COL_ACTIVE,1);#on le met actif
			$found = 1;
			#$combo->set_active($tab[0]);
			gestion_display_combobox();#afficher le bon hélico dans le combobox
			return 1;
		  }
	});
  if ($found) {
	return 1;
  } else {
	$combo->set_active(-1);
	return 0;
  }
}




my ($helitype,$heliname);
#fonction pas appelée au bon moment
sub confirm_fill {
  if ($asswin->get_page_complete($nom_page)) {#si la page nom est dument remplie
	$heliname = $text;
	$helitype = get_active_label();
	if (defined($helitype) && $heliname ne '') {
	  $confirm_page->set_text("\tType l'hélicoptère : $helitype\n\tNom de l'hélicoptère : $heliname\n");
	  $asswin->set_page_complete($confirm_page,1);
	  resume_fill();
	  $asswin->signal_connect(apply	 => \&create_heli);
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
  #$asswin->signal_connect(apply	 => \&do_close);
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
	$asswin->set_page_complete($nom_page,0);
	return 0;#aucun id actif
  }
  gestion_display_combobox();###########test#################
}

#verifie que l'entrée est valide (nom et type)
sub valid_entry {
  $text = $entry->get_text();
  if($text =~ /^\d+$/ && $combo->get_active() != -1) {
	$asswin->set_page_complete($nom_page,1);
	confirm_fill();
	return 1;
  } else {
	$asswin->set_page_complete($nom_page,0);
	return 0;
  }
}

sub get_type_and_heli {
  if ($asswin->get_page_complete($confirm_page)) {
	return {type => $helitype, nom => $heliname};
  }
}

my $once = 0;
#TODO: remplir l'erreur + trouver mieux que once
sub create_heli {
  if (!$asswin->get_page_complete($resume_page) && $once == 0) {
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
	  $asswin->set_page_complete($resume_page,1);
	  $once = 1;
	  $asswin->signal_connect(apply => \&do_close);
	  return next_page();
	} else {
		warn "erreur\n";
	  return 0;
	}
  }
}

#importe d'apres un dossier
sub import_assist {
  my $heli = shift;
  if (administration::importWin::Import::extraire($heli)) {
	return 1;
  } else {
	return 0;
  }
}

sub do_close {
  shift->destroy();
}

sub next_page {
  $asswin->set_current_page($asswin->get_current_page()+1);
}

1;
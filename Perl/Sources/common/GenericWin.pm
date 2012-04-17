package GenericWin;

use strict;
use utf8;
use Glib;

my $window;
my $strings;

#fonction appelé par main au demmarrage
sub init {
  $window = shift; #recueration de la fenetre parent helimasse0
  #$strings = main::get_strings();
}

=pod
@description
	permet de créer une fenetre munie d'une entrée texte
@param
	1)ref->une refercence vers un tableau à double entrée : en ligne les chaines en colone le groupe et la clé
@return
	le texte entré et 1 si l'utilisateur appuie sur ok (ou enter)
	(undef,0) sinon (annuler)
@requires
  administration::adminWin::Controller::adminwin
=cut
sub entreetext {
	my $content = shift;
	my $question = main::get_string([$content->[0][0],$content->[0][1]]);
	my $precision = main::get_string([$content->[1][0],$content->[1][1]]);
	my $titre = main::get_string([$content->[2][0],$content->[2][1]]);
	my $messwindow = Gtk2::MessageDialog->new (undef,'modal','question','ok-cancel',$question);#construction de la fenetre
	my $textentry = Gtk2::Entry->new;#création d'un zone d'entrée texte
	#paramètrage de la fenetre de dialogue
	$messwindow->set_title($titre);
	$messwindow->get_content_area->add($textentry);#implementation de la zone dans la boite de dialogue
	$messwindow->format_secondary_text($precision) if (defined($precision));#texte secondaire
	$messwindow->set_default_response('ok');#reponse par defaut est ok
	#paramétrage de l'entrée texte
	$textentry->set_visibility(0);#caractères invisibles
	$textentry->show;#montrer la zone
	$textentry->set_activates_default(1);#enter applique l'action par default

	#affichage de la fenètre
	my $reponseut = $messwindow->run();

	#si l'utilisateur appuie sur valider
	if ($reponseut eq 'ok') {
		my $text = $textentry->get_text();#recuperation du mot de passe dans la zone de texte
		$messwindow->destroy;#destruction de la fenetre
		return ($text,1);#envoi du texte saisi
	} elsif ($reponseut eq 'cancel') {
		#sinon l'utilisateur a appuyé sur annuler
		$messwindow->destroy;#destruction de la fenetre
		return (undef,0);#fin
	} elsif ($reponseut eq 'delete-event') {
      return (undef,0);
   }
}

=pod
@description
	permet d'afficher une boite de dialogue de type 'oui non' avec une message principal et un message secondaire evenuel
@param
	1)String->message principal
	2)String (optional)->message secondaire
@return
	1 si l'utilisateur a dit oui
	0 s'il a dit non
@depends
	administration::ImportExport::importer|exporter|modifier
=cut
sub ouinon {
	my $content = shift;#recuperation des paramètres
	my $msgprinc = main::get_string([$content->[0][0],$content->[0][1]]);
	my $msgsecon = main::get_string([$content->[1][0],$content->[1][1]]);
	my $diagouinon = Gtk2::MessageDialog->new($window,'destroy-with-parent', 'question', 'yes-no',$msgprinc);# création de la boite de dialoge
 	#parametrage
 	$diagouinon->format_secondary_text($msgsecon) if (defined($msgsecon));#parametrage eventuel du message secondaire
 	my $reponseut = $diagouinon->run;#ouvertur de la fenetre de dialogue
 	if ($reponseut eq 'yes') {
 		$diagouinon->destroy();#destruction de la fenetre
 		return 1;#a dit oui
 	} elsif($reponseut eq 'no') {
 		$diagouinon->destroy();
 		return 0;#a dit non
 	} elsif($reponseut eq 'delete-event') {
      $diagouinon->destroy;
      return 0;
   }
}

=pod
@description
	créé une fenetre de type selecteur de fichiers
@param
	1) String -> titre de la fenetre et du bouton valider
	2) String ->correspond au type du filechooser (ex: 'save' ou 'open')
   3) String (Optionnel) -> 'data','pdf' = nom du filtre à utiliser
   4) String (Optionnel) -> nom a afficher dans la barre de texte en haut
@return
	le path vers le fichier si ok est cliqué
	0 sinon
@depends
	administration::ImportExport::Importer|Exporter
=cut
sub filechooser {
  my $titre = shift;
  $titre = main::get_string([$titre->[0][0],$titre->[0][1]]);
  my $fonction = shift;
  my $type = shift;
  my $name = shift;
  my $folder = $ENV{HOME};
  erreur_msg([['erreurs','fonction_filechooser'],['erreurs','param_filechooser']]) if(!defined($fonction));
  my $filechooser = Gtk2::FileChooserDialog -> new($titre,$window,$fonction, ("Annuler" => 'cancel', $titre => 'accept'));#creation
  $filechooser->set_current_folder($folder) if (defined($folder));
  if ($type eq 'data') {
    my $filefilter = Gtk2::FileFilter->new();#filtre pour les données
    $filefilter->add_mime_type("plain/text");#que des données de texte
    $filefilter->add_pattern('*.dat');#que des .dat
    $filefilter->set_name("data file");#titre
    $filechooser->add_filter($filefilter);#ajout du filtre
    $filechooser->set_filter($filefilter);#utilisation du filtre
  } elsif ($type eq 'pdf') {
    my $filefilter = Gtk2::FileFilter->new();#filtre pour les données
    $filefilter->add_mime_type("application/pdf");#que des données de texte
    $filefilter->add_pattern('*.pdf');#que des .dat
    $filefilter->set_name("pdf file");#titre
    $filechooser->add_filter($filefilter);#ajout du filtre
    $filechooser->set_filter($filefilter);#utilisation du filtre
  } elsif ($type eq 'zip') {
	my $filefilter = Gtk2::FileFilter->new();#filtre pour les zip
	$filefilter->add_mime_type("application/zip");#que des zip
    $filefilter->add_pattern('*.zip');#que des .zip
    $filefilter->set_name("zip file");#titre
    $filechooser->add_filter($filefilter);#ajout du filtre
    $filechooser->set_filter($filefilter);#utilisation du filtre
  }
  $filechooser->set_current_name($name) if (defined($name));#nom par defaut dans la barre
  $filechooser->set_do_overwrite_confirmation(1);#demander pour ecraser
  my $reponseut = $filechooser->run();#demarrage de la fenetre
  if ( $reponseut eq 'accept') {
    my $path = $filechooser->get_filename();
	$filechooser->destroy;
    return($path);
  } elsif ($reponseut eq 'cancel') {
	$filechooser->destroy; #on ferme la fenetre
	return undef;
  } elsif ($reponseut eq 'delete-event') {#suppression par le bouton suppr de la fenetre
    $filechooser->destroy;
    return undef;
  }
}
=pod
@description
	créé un boite de dialogue de type info
@param
	1)GtkWidet->le widget parent (qui appelle la boite)
	2)String->Le titre de la fenetre
	3)String (optionel)->le message à montrer dans la fenetre
=cut
sub info {
    my $content = shift;
	my $var = shift || '';
#recuperation du titre et du message eventuel
	my $titrewin = main::get_string([$content->[0][0],$content->[0][1]]);
	my $titre = main::get_string([$content->[1][0],$content->[1][1]]);
	my $message = main::get_string([$content->[2][0],$content->[2][1]]);
	$message .= $var;
    my $infowin = Gtk2::MessageDialog->new($window,'destroy-with-parent','info','close',$titre);#création de la fenetre
    $infowin->format_secondary_text($message) if (defined($message));#texte secondaire eventuel
    $infowin->set_title($titrewin);
	 my $reponseut = $infowin->run();
	 $infowin->destroy();
}

=pod
@description
  créée une boite de dialogue avec un message principal et un message secondaire
@param
  1)String->message d'erreur principal
  2)String (optional)->message d'errueur secondaire eventuel
@return
  1
=cut
sub erreur_msg {
  my $content = shift;
  my $var = shift;
  $var = '' if (!defined($var));
  my $msgprinc = main::get_string([$content->[0][0],$content->[0][1]]);
  my $msgsecond;
  if(defined($content->[1][0])) {
	$msgsecond = main::get_string([$content->[1][0],$content->[1][1]]);
  } else {
	$msgsecond = '';
  }
  $msgsecond .= $var;
  my $diagerreur = Gtk2::MessageDialog->new ($window,
                                  'modal',
                                  'error',
                                  'close',
                                  $msgprinc);# création de la boite de dialoge
  $diagerreur->format_secondary_text($msgsecond) if (defined($msgsecond));#parametrage eventuel du message secondaire
  $diagerreur->run;#ouvertur de la fenetre d'erreur
  $diagerreur->destroy;#fermeture de la fenetre
  return 1;
}

=pod
@description
	créée une boite de dialog avec un message principal et un message secondaire et quite le programme
@param
	1)String->message d'erreur principal
	2)String (optional)->message d'erreur secondaire eventuel
@return
	->fin du programme
=cut
sub erreur_end {
  my $content = shift;#recuperation des paramètres
  my $var = shift;
  $var = '' if (!defined($var));
  erreur_msg ($content,$var);#appel de la fonction précèdente
  exit(-1);#fermeture du programme
}
1;
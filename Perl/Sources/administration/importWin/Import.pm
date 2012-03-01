package administration::importWin::Import;
#TODO:verfier que ca marche sur windowbe aussi!

use strict;
use utf8;
use IO::Uncompress::Unzip qw(unzip $UnzipError);
use File::Spec;
use Digest::SHA;

my $heli_dir;
my $base_dir;
my $tmp_dir;
#my $strings;

use LoadDat;
#changer ca!!
use Archive::Extract;

use constant SECTION_TYPE => 0;
use constant SECTION_NOM  => 1;
use constant SECTION_SHA  => 2;

sub init {
  $heli_dir = shift;
  $base_dir = shift;
  $tmp_dir = File::Spec->catdir($base_dir,'tmp');
  #$strings = main::get_strings();
}

=pod
description
	demande le chemin d'importation à l'utilisateur
return
	1 si tout c'est bien passé
	0 sinon
requires
	administration::AdminWin
=cut
sub importer {
    my $path = undef;
	 my $reponse = 0;
	 while (!$reponse && !defined($path)) {
		$path = GenericWin::filechooser([['titres','importer']],'open','zip');
		return 0 if(!defined($path));#si l'utilisateur appuie sur annuler, on quitte la boucle
		if($reponse !=1) {$reponse = GenericWin::ouinon([['messages','importer_confirm_main'],['messages','importer_confirm_sub_end']]);}#reponse de l'utilisateur au oui non
		}
	 if (defined($path)){#si l'utilisateur a appuyé sur ok 2 fois
	  scan($path);
	 }
}
=pod
@description
  extrait l'archive de premier niveau et scanne le contenu de .info.dat
@param
  1)String->le chemin d'importation de l'utilisateur
=cut
sub scan {
  my $path = shift;#on recupere le path de l'util
  my $ready = shift;
  unzip $path => File::Spec->catfile($tmp_dir,'.info.dat') ,Name => '.info.dat' or GenericWin::erreur_msg([['erreurs','importer_fail']],$UnzipError);#on extrait le .info.dat dans le fichier temp

  my $resume = LoadDat::load(File::Spec->catfile($tmp_dir,'.info.dat'));#on le charge
  if (defined($resume)) {#on le lit
	my $nomheli = $resume->[SECTION_NOM]->{contenu}->[0][0];
	my $typeheli = $resume->[SECTION_TYPE]->{contenu}->[0][0];
	my $shaheli = $resume->[SECTION_SHA]->{contenu}->[0][0];
	unzip $path => File::Spec->catfile($tmp_dir,$nomheli.'zip.zip'), Name => $nomheli.'zip.zip'  or GenericWin::erreur_msg([['erreurs','importer_zipzip']],$UnzipError);#on extrait l'archive avec les vraies données
	my $sha = Digest::SHA->new(256);
	$sha->addfile(File::Spec->catfile($tmp_dir,$nomheli.'zip.zip'));
	my $shasum = $sha->hexdigest;#on calcul son shasum
	if ($shasum eq $shaheli){#s'il est le même qu'a l'empaquetage
	  if (!defined($ready)){#si on est pret
		extraire({dossier=>$typeheli, nom=>$nomheli});#on lance l'extraction
	  } else {
		return ({dossier =>$typeheli, nom=>$nomheli});#on retourne juste le nom et le type
	  }
	} else {
	  GenericWin::erreur_msg([['erreurs','importer_corrupt']]);#sinon on annule tout (faut pas exagerer)
	  return (undef,undef);
	}

	unlink(File::Spec->catfile($tmp_dir,'.info.dat'));#on supprime le fichier tempo
	return 1;

  } else {
	GenericWin::erreur_msg([['erreurs','importer_load']]);
	return 0;
  }
}
#TODO: trouver comment faire avec unzip direct....
#c'était juste plus court de faire comme ca maintenant
=pod
@description
  extrait les données .dat de l'archive et les place dans le bon dossier
@param
  1)String-> le type de l'hélico
  2)String->le nom de l'hélico
=cut
sub extraire {
  my $heli = shift;
  #on charge l'archive
  my $nomheli = $heli->{nom};
  my $typeheli = $heli->{dossier};
  my $generic = 0;
  my $extractfile;
  if (defined($heli->{generic})) {
	$generic = $heli->{generic};
	$extractfile = Archive::Extract->new(archive => File::Spec->catfile($tmp_dir,$typeheli.'zip.zip'));
  } else {
	$extractfile = Archive::Extract->new(archive => File::Spec->catfile($tmp_dir,$nomheli.'zip.zip'));
  }
  #on lance l'extraction
  if ( $extractfile->extract(to=>(File::Spec->catdir($base_dir,'helicos',$typeheli,$nomheli))) ) {
    GenericWin::info([['titres','reussite'],['messages','importer_restart_main'],['messages','restart_sub']]);
	#on supprime le fichier temp sauf si c'est un fichier générique (= de type d'hélico)
	unlink(File::Spec->catfile($tmp_dir,$nomheli.'zip.zip')) unless $generic;
	return 1;
  } else {
    GenericWin::erreur_msg([['erreurs','importer_fail']],$UnzipError);
	return 0;
  }
}
1;
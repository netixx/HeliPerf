package file::Config;

use strict;
use LoadDat;

=pod
Charge le fichier de configuration contenant la liste des hélicos et le mot de passe
renvoie un tableau de {nom => nom de l'hélico, dossier => répertoire de l'hélico} avec le mot de passe couplé,

load($filename) : $filename nom du fichier à lire
=cut

#Numéro de la section helicos apparaissant dans le fichier config.dat
use constant SECTION_TYPEHELICOS => 0;
use constant SECTION_HELICOS => 1;
use constant SECTION_MOTDEPASSE => 2;

use constant COL_DOSSIER  => 1;
use constant COL_TYPE     => 0;
use constant COL_NOM      => 0;


#ca me parait clair
#renvoie undef si erreur
sub load {
  my ($base_filename) = @_;
  my $base = LoadDat::load($base_filename);

  if (!$base) {
    GenericWin::erreur_msg("Impossible de charger le fichier de configuration $base_filename : ".LoadDat::get_erreur);
    return undef;
  }

  #Récuperation de la liste des types d'hélicos
  my $obj = $base->[SECTION_TYPEHELICOS];
  my @tab_typeheli = ();
  foreach my $ligne (@{$obj->{contenu}}) {
    push @tab_typeheli, {type => $ligne->[COL_TYPE], dossier => $ligne->[COL_DOSSIER]};
  }

  #Récupération de la liste des hélicos
  $obj = $base->[SECTION_HELICOS];
  my @tab_heli = ();
  foreach my $ligne (@{$obj->{contenu}}) {
    push @tab_heli, { nom => $ligne->[COL_NOM], dossiertype => $ligne->[COL_DOSSIER] };
  }

  # if (!$base) {
    # GenericWin::erreur_msg("Impossible de charger le fichier de configuration $base_filename : ".LoadDat::get_erreur);
    # return undef;
  # }

  #Récupération des mots de passe
  #Première ligne, premier élément
  my $mdpadmin = $base->[SECTION_MOTDEPASSE]->{contenu}->[0][0] ;
  my $mdpsuperadmin = $base->[SECTION_MOTDEPASSE]->{contenu}->[1][0];
  ############################################################################################
  #dev echanger les 2 premiers parametres -> fait                                            #
  ############################################################################################
  return (\@tab_heli,\@tab_typeheli, $mdpadmin, $mdpsuperadmin);
}

1;

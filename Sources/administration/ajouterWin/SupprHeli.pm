package administration::ajouterWin::SupprHeli;
#TODO: Supprimer l'hélico de config.dat aussi
=pod
@description
  permet de gerer la suppression d'un hélico
@list
  init, supprimer_helico_load,select,supprimer_helico
=cut
use strict;
use utf8;
use File::Spec;
use File::Path;#pour pouvoir supprimer en cascade

use ManageList;
use GenericWin;

my $listehelico;
my $base_dir;# = main::get_base_dir();
my $strings;
#recuperation du repertoire de base de l'application
sub init {
  $strings = main::get_strings();
  $base_dir = shift;
}

#chargement de la liste des hélicos
sub supprimer_helico_load {
  $listehelico = ManageList::construct_heli();
}
=pod
@description
  selectionne les hélicos dans la liste en fonction du choix de l'utilisateur
@param
  1) int -> l'id cliqué par l'utilisateur
=cut
sub select {
  my $iter = $listehelico->iter_nth_child(undef,shift);
  if (($listehelico->get($iter, ManageList::COL_ACTIVE))[0]) {
    $listehelico->set($iter, ManageList::COL_ACTIVE, 0);#on desactive si actif
  } else {
    $listehelico->set($iter, ManageList::COL_ACTIVE, 1);#on active si inactif
  }
}
=pod
@description
  supprime un hélico et quitte l'application
=cut
sub supprimer_helico {
  $listehelico->foreach( sub {
      my $iter = $_[2];
      if (($listehelico->get($iter, ManageList::COL_ACTIVE))[0]) {
        my $helico = ($listehelico->get($iter, ManageList::COL_LABEL))[0];
        my @tab = split(/ - /,$helico);
        my @heli = ManageList::find_diretheli_byname(\$tab[1]);
        #die File::Spec->catdir($base_dir,'helicos',@heli);
        chdir($base_dir) or GenericWin::erreur_msg('Erreur lors du changement de répertoire',"$!");
        if (GenericWin::ouinon([['messages','supprimer_confirm_main'],['message','restart_confirm_sub']])){
          my $nfichier = rmtree(File::Spec->catdir($base_dir,'helicos',@heli));
          Config::KeyFileManage::del_helico({nom=>$heli[1]});
          GenericWin::erreur_end([['messages','restart_sub'],['messages','supprimer_nombre']]);
        }
      }
  });
  #ManageList::reset_heli(); sert a rien (pour le moment) vu qu'on quitte
}

1;

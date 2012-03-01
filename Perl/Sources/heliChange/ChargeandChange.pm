package heliChange::ChargeandChange;
=pod
@description
	permet de changer l'hélicoptère sur lequel l'utilisateur travailles
@list
	init,set_helico_idx_active,changerheli,annulerchange
@depends
	heliChange::Controller
=cut

use strict;
use Glib;
use utf8;
use File::Spec;

use GenericWin;


my $listehelico;
my $activeid = mainWin::Controller::DEFAULTHELI;#helico actif par defaut = helico chargé par defaut
my $activeidstore = $activeid;#sauvegarde de l'id au cas ou l'utilisateur annuler
my $helicos;
#chargement intial du tableau

sub init {
  $listehelico = ManageList::construct_heli();
  $helicos = Config::KeyFileManage::get_helicos();
  $listehelico->set($listehelico->iter_nth_child (undef,$activeid), ManageList::COL_ACTIVE, Glib::TRUE);#activation de l'hélico actif
}

=pod
@description
	change l'hélico actif dans la liste par celui sur lequel l'utilisateur clique
@param
	1)Int->id de l'hélico cliqué (entre 0 et n-1)
@requires
	heliChange::Controller::on_toggled_radio
=cut
sub set_helico_idx_active {
  my $id = shift;#recup de l'id
  $listehelico->set($listehelico->iter_nth_child (undef, $activeid), ManageList::COL_ACTIVE, Glib::FALSE);#on désactive l'ancien
  $listehelico->set($listehelico->iter_nth_child (undef, $id), ManageList::COL_ACTIVE, Glib::TRUE);#on active le nouveau
  $activeid = $id;#on remplace l'id actif par l'id cliqué
}

=pod
@description
	change l'hélico en cours d'utilisation par celui d'id 'activeid' en demandant une confirmation à l'utilisateur
@param
	1)GtkWindow-> la fenetre changer (pour fermeture dans la suite)
@depends
	mainWin::Controller::set_helico
@requires
	heliChange::Controller::validerchangheli
=cut
sub changerheli {
  my $windowchange = shift;
  if($activeid != $activeidstore) {
		if (GenericWin::ouinon([['messages','changer_heli_main'],['messages','changer_heli_sub']])) {#si l'util appui sur ok
			mainWin::Controller::set_helico($helicos->[$activeid]);#on change l'helico
			$activeidstore = $activeid;#on sauvegarde l'hélico actif
			OpenandCloseWin::close_souf(undef,$windowchange);
         ManageList::reset_heli();
		} else {#l'util appuie sur non
			annulerchange();#on annule
		}
  }
}

=pod
@description
	annule le changement demandé par l'utilisateur
@depends
	set_helico_idx_active
@requires
	heliChange::Controller::annulerchangheli
=cut
sub annulerchange {
  set_helico_idx_active($activeidstore);#on remet le bon id comme actif
  $activeid = $activeidstore; #on ecrase l'active id par l'ancien
  ManageList::reset_heli();
}
1;

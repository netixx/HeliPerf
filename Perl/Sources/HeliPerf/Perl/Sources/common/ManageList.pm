package ManageList;
=pod
@description
  s'occupe de gerer les listes (activation,desactivation, création) et de rechercher des objets dedans
@list
  init_type, construct_type, reset_type, init_heli,construct_heli, reset_heli
  find_diretheli_byname
=cut
use strict;
use Glib;
use utf8;

my ($listetypehelico,$listehelico);
my $treestring;
use constant COL_ACTIVE => 0;
use constant COL_LABEL  => 1;
use constant COL_GROUPE	=> 0;
use constant COL_CLE	=> 1;
use constant COL_VALEUR	=> 2;

=pod
@description
  routine qui recupere la table de hachage doit etre appele lors de l'ajout d'un helico
@param
  1)Hash (optionel)->table de hachage des helicos
  2)GtkListstore (optionel)>liststore graphique
=cut
sub init_type {
  my $listetypehelicotrans = shift;
  $listetypehelico = $listetypehelicotrans if (defined($listetypehelicotrans));
}

sub init_heli {
  my $listehelicotrans = shift;
  $listehelico = $listehelicotrans if (defined($listehelicotrans));
}

sub init_strings {
  $treestring = shift;
}
=pod
@description
  efface et construit la liste des helicos
@return
  1)liststore rempli
  2)la table de hachage des helicos
=cut
sub construct_heli {
  $listehelico->clear();
  my $helicos = Config::KeyFileManage::get_helicos();
  foreach my $helico (@$helicos) {#construction du tableau
    my $iter = $listehelico->append;
    my $type_et_nom = $helico->{type};
    $type_et_nom .= ' - ';
    $type_et_nom .= $helico->{nom};
    $listehelico->set($iter, COL_ACTIVE, Glib::FALSE, COL_LABEL, $type_et_nom);
  }
  return $listehelico;
}

=pod
@description
  remet les indicateurs a zero apres une manipulation
=cut
sub reset_heli {
   $listehelico->foreach(sub {
		  my $iter = $_[2];
          $listehelico->set($iter,COL_ACTIVE,0);
    });
  #for (my $id = 0;$id<scalar(@$helicos);$id++) {
  #  $listehelico->set($listehelico->iter_nth_child (undef, $id),COL_ACTIVE, Glib::FALSE);#remise à zero de la colone 'actif'
  #}
}

=pod
@description
  efface et construit la liste des helicos
@return
  1)liststore rempli
  2)la table de hachage des types d'helico
=cut
sub construct_type {
  $listetypehelico->clear();
  my $typehelicos = Config::KeyFileManage::get_typehelicos();
  foreach my $typehelico (@$typehelicos) {#construction du tableau
    my $iter = $listetypehelico->append;
    $listetypehelico->set($iter, COL_ACTIVE, 0, COL_LABEL, $typehelico->{type});
  }
  return $listetypehelico;
}

=pod
@description
  remet les indicateurs a zero apres une manipulation
=cut
sub reset_type {
  $listetypehelico->foreach(sub {
		  my $iter = $_[2];
          $listetypehelico->set($iter,COL_ACTIVE,0);
    });
  #for (my $id = 0;$id<scalar(@$typehelicos);$id++) {
  #  my $iterid = $listetypehelico->iter_nth_child (undef, $id);
  #  $listetypehelico->set($iterid, COL_ACTIVE, 0);#remise à zero de la colone 'actif'
  #}
}
my @paths = ();
sub fill_tree_strings {
  my $strings = main::get_strings();
  my @groups = keys %$strings;
  foreach my $group (@groups) {
	my @keys = keys %{$strings->{$group}};
	my $parentiter = $treestring->append(undef);
	$treestring->set($parentiter,COL_GROUPE, $group);
	foreach my $key (@keys) {
	  my $iter = $treestring->append($parentiter);
	  $treestring->set($iter,COL_CLE, $key, COL_VALEUR, $strings->{$group}{$key});
	}
  }
}

sub get_tree_strings {
  my $strings = {};
  my $iterparent = $treestring->get_iter_first();
  my $nparent = $treestring->iter_n_children(undef);
  for(my $j = 1;$j<=$nparent;$j++) {
	my $group = $treestring->get($iterparent, COL_GROUPE);
	my $nchildren = $treestring->iter_n_children($iterparent);
	my $iterchild = $treestring->iter_children($iterparent);
	for(my $i = 1;$i<=$nchildren;$i++) {
	  my $key = $treestring->get($iterchild,COL_CLE);
	  my $value = $treestring->get($iterchild,COL_VALEUR);
	  $strings->{$group}{$key} = $value;
	  $iterchild = $treestring->iter_next($iterchild);
	}
  $iterparent = $treestring->iter_next($iterparent);
  }
  return $strings;
}

sub get_tree_strings_changed {
  my $strings_changed = {};
  foreach my $path (@paths) {
	my $iter = $treestring->get_iter_from_string($path);
	my $parent = $treestring->iter_parent($iter);
	my $group = $treestring->get($parent,COL_GROUPE);
	my $key = $treestring->get($iter,COL_CLE);
	my $value = $treestring->get($iter,COL_VALEUR);
	$strings_changed->{$group}{$key} = $value;
  }
  return $strings_changed;
}

sub edit_tree_cell {
  my $content = shift;
  push @paths,$content->{path};
  my $iterchanged = $treestring->get_iter_from_string($content->{path});
  $treestring->set($iterchanged,COL_VALEUR, $content->{text});
}


#TODO: utiliser la liste des types d'hélicos pour rechercher le dossier et changer le dossier par le nom du type dans config.dat
=pod
@description
  trouve le dossier et l'hélico à partir du nom
@param
  1)reference -> reference vers le nom de l'hélico
@return
  1)Tab -> tableau de [dossiertype,nom] (ideal pour catdir)
=cut
sub find_diretheli_byname {
  my $rheliname = shift;
  my $helicos = Config::KeyFileManage::get_helicos();
  foreach my $heli (@$helicos) {
    if ($heli->{nom} eq $$rheliname) {
      return ($heli->{dossiertype},$heli->{nom});
    }
  }
  return undef;
}
1;

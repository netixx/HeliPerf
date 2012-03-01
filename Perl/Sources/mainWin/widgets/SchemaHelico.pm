package mainWin::widgets::SchemaHelico;
#TODO: faire une base de données commune avec ListeMatos du matériel utilisée
#TODO: afficher message d'erreur si on ne peut afficher l'image
#TODO: mettre une méthode id dans item pour afficher un identifiant au lieu du nom pour la table de hachage
#TODO: afficher les tooltips quand on passe le curseur dessus
#pb : charge les images à chaque réutilisation
#s'occupe du schéma de l'hélico
#reverse
=pod
Ce module s'occupe du schéma de l'hélico, en représentant les différents items sur ce schéma sus-nommé.
Seules les images png sont supportées

init($drawingarea, $imgdir) : à l'issue, le module travaillera sur le GtkDrawingArea donné en paramètre
  et cherchera les images dans le dossier $imgdir

new($imgfile) : efface tout item affiché et affiche l'image $imgfile en fond (typiquement le schéma de l'hélico)
=cut

use strict;
use Glib;
use Cairo;

use File::Spec;

use GenericWin;
use DrawingArea;

#seul les images png sont supportés

#image de l'hélico en mémoire (chargé par new)
my $surface_helico;
my ($schemaratiox,$schemaratioy,$schemaoffsetpixx,$schemaoffsetpixy);
#Table de hachage $item => {surface => surface($item=>img), posx => $item->get_bras, posy => $item->get_bras_l, item=>$item}
#base des surfaces à afficher
my %surfaces ;
my %dragables ;
#objet facilitant la gestion des GtkDrawingArea (cf DrawingArea)
my $oDrawingArea;

#répertoire de recherche des images
my $img_dir;
use constant TARGET => ['image', 'same-widget', 0];
sub init {
  my ($area, $aimg_dir) = @_;
  $img_dir = $aimg_dir;

  #largeur et hauteur initiale : 0
  $oDrawingArea = DrawingArea->new($area, \&_draw_func, \&_on_conf_func, 0, 0);
  #Affiche les infobulles
  $area->set_has_tooltip(Glib::TRUE);
  $area->signal_connect( query_tooltip => \&_query_tool_tip );

	my $target = TARGET;
	# $area->drag_dest_set(['drop', 'motion'], 'move', $target);
	# $area->drag_source_set ('button1-mask', 'move', $target);

	my $el;
	# $area->signal_connect(drag_begin =>\&_drag_begin  , \$el    );
	# $area->signal_connect(drag_data_get      => \&_drag_get, $el     );
	# $area->signal_connect(drag_data_received => \&_drag_received, $el);
	# $area->signal_connect(drag_drop => \&_drag_drop, \$el);
#	'button-press-mask', 'leave-notify-mask'
	$area->add_events(['pointer-motion-hint-mask','button-press-mask', 'button-release-mask' ]);
	$area->signal_connect( button_press_event => \&_button_press, \$el);
	$area->signal_connect( button_release_event => \&_button_release, \$el);
	$area->signal_connect( motion_notify_event => \&_mouse_motion, \$el);
}

sub new {
  my $helico = shift;
  my $imgfile = $helico->get_img();
  $schemaratiox = $helico->get_schemaratiox();
  $schemaratioy = $helico->get_schemaratioy();
  $schemaoffsetpixx = $helico->get_schemaoffsetpixx();
  $schemaoffsetpixy = $helico->get_schemaoffsetpixy();
  #Plus d'item à afficher
  %surfaces = ();
  %dragables = ();
  #charge en mémoire le schéma de fond
  $surface_helico = _load_png ($imgfile);

  #S'il n'y a pas de pb
  if ($surface_helico) {
    my $w = $surface_helico->get_width ();
    my $h = $surface_helico->get_height();

    #actualise la taille de GtkDrawingArea
    $oDrawingArea->area->set_size_request($w, $h);
    $oDrawingArea->create_new_cr($w, $h);
#    $oDrawingArea->update();
  }
}

#Permet de mettre à jour graphiquement
sub update {
  $oDrawingArea->update();
}

=pod
_load_png($imgfile, $refobj)
Charge le fichier png en paramètre, renvoie true s'il n'y a pas de pb, affiche un msg d'erreur sinon

_load_png($file_name, $surface) où surface est une référence vers une variable
=cut
sub _load_png {
  my $imgfile = shift;

  #Charge le fichier à partir du répertoire $img_dir
  my $surface = Cairo::ImageSurface->create_from_png (File::Spec->catfile($img_dir,$imgfile));

  my $status = $surface->status;
  #vérificationd de la validité de la surface
  if  ($status eq 'success') {
    #return true
    return $surface;
  }
  else {
    GenericWin::erreur_msg([['erreurs','image_load']],$imgfile.':'.$status);
    #return false
    return undef;
  }
}

=pod
Callbacks utilisés pour la création de l'objet DrawingArea
=cut
sub _draw_func {
  my $cr = $oDrawingArea->cr; #shift;

  #si la surface est bien définie (il peut y avoir pb de chargement)
  if (defined($surface_helico))
  {
    #dessin du schéma de fond de l'hélico
    $cr->set_source_surface($surface_helico, 0., 0.);
    $cr->paint;
  }

  #dessin de chaque item
  foreach my $surface (values(%surfaces))
  {
    $cr->set_source_surface($surface->{surface}, $surface->{posx}, $surface->{posy});
    $cr->paint;
  }

  #dessin de chaque item
  foreach my $surface (values(%dragables))
  {
    $cr->set_source_surface($surface->{surface}, $surface->{posx}, $surface->{posy});
    $cr->paint;
  }
}


sub _on_conf_func {
}

=pod
Ajoute un matériel $item à afficher en plus.
Elle utilise également la méthode $item->set_delete_SchemaHelico_func

Prends en paramètre un objet item implémentant les méthodes suivantes :
$item->get_nom : identifiant unique
$item->get_bras
$item->get_bras_l
$item->get_img : adresse de l'image
$item->set_delete_SchemaHelico_func ($func) : permet à l'item de supprimer l'item du en appelant la fonction $func.
=cut
sub ajoute {
  my $controllerItem = shift;
  my $item = $controllerItem->get_model;
  #GenericWin::erreur_msg ($item->get_nom);
  my $callback = sub {};
  my $imgfile = $item->get_img;
  #Si l'item a une image associée
  if ($imgfile)
  {
    #chargement en mémoire de l'image
    my $surface = _load_png($imgfile);
    # vérification
    if ($surface) {
      #placement de l'image
      my ( $x, $y) = _calc_pos ($item->get_bras, $item->get_bras_l, $surface->get_width(), $surface->get_height());
      my $id = $item->get_id;

      if ($item->is_dragable) {
	      #ajout dans la base des surfaces à dessiner
	      $dragables{$id} = {surface => $surface, posx => $x, posy => $y, item => $controllerItem};
	      #fonction permettant de supprimer l'image de la liste à afficher
	      $callback = sub { delete ($dragables{$id}); };
      }
      else {
	      #ajout dans la base des surfaces à dessiner
	      $surfaces{$id} = {surface => $surface, posx => $x, posy => $y, item => $controllerItem};
	      #fonction permettant de supprimer l'image de la liste à afficher
	      $callback = sub { delete ($surfaces{$id}); };
      }
    }

  }

  $controllerItem->set_delete_SchemaHelico_func ($callback);
}

#calcul de la position de l'image de dimension $w * $h
sub _calc_pos {
  my ( $brax, $bray, $w, $h) = @_;
  my $pixx = $brax * $schemaratiox - $w/2 - $schemaoffsetpixx ;
  my $pixy = ($surface_helico->get_height())/2 - $h/2 + $schemaoffsetpixy - ($bray*$schemaratioy);
  #Pour que ce soit bien centré
  return ($pixx , $pixy);
}

sub _pos_calc {
	my ($pixx, $pixy,$surface) = @_;
   my ($w,$h)=($surface->get_height(),$surface->get_width());
   my $brasx =($pixx + $w/2 + $schemaoffsetpixx)/ $schemaratiox;
   my $brasy =-($pixy + $h/2 - $schemaoffsetpixy - $surface_helico->get_height()/2)/ $schemaratioy;
	return ($brasx,$brasy);
}

#Lorsqu'il faut afficher une infobulle (fonction callback appelé par Gtk grâce à SchemaHelico::init
sub _query_tool_tip {
  my ($widget, $x, $y, $keybord_mode, $tooltip) = @_;

  #par cours des surfaces
	# foreach my $el (%surfaces)
  foreach my $table (values (%surfaces)) {
    #si la souris pointe sur l'image associée
    my $rect = Gtk2::Gdk::Rectangle->new($table->{posx}, $table->{posy}, $table->{surface}->get_width, $table->{surface}->get_height);
    if (Gtk2::Gdk::Region->rectangle($rect)->point_in($x, $y) == Glib::TRUE) {
      #affichage du nom de l'item dans l'infobulle
      $tooltip->set_text($table->{item}->get_model->get_nom);
      return Glib::TRUE;
    }
  }

  foreach my $table (values (%dragables)) {
    #si la souris pointe sur l'image associée
    my $rect = Gtk2::Gdk::Rectangle->new($table->{posx}, $table->{posy}, $table->{surface}->get_width, $table->{surface}->get_height);
    if (Gtk2::Gdk::Region->rectangle($rect)->point_in($x, $y) == Glib::TRUE) {
      #affichage du nom de l'item dans l'infobulle
      $tooltip->set_text($table->{item}->get_model->get_nom);
      return Glib::TRUE;
    }
  }
  #l'infobulle n'est pas affichée puisque la souris ne pointe sur aucun item
  return Glib::FALSE;
}

sub _button_press {
	my ($widget, $event, $el ) = @_;
	my ($x, $y) = $event->get_coords;
	while( my ($cle,$table) = each(%dragables) ) {
    #si la souris pointe sur l'image associée
    # my $rect = Gtk2::Gdk::Rectangle->new($table->{posx}, $table->{posy}, $table->{surface}->get_width, $table->{surface}->get_height);
		my $offsetx = $x - $table->{posx};
		my $offsety = $y - $table->{posy};
		my $width = $table->{surface}->get_width;
		my $height = $table->{surface}->get_height;

    if (0 <= $offsetx && $offsetx <= $width && 0 <= $offsety && $offsety <= $height) {
      #affichage du nom de l'item dans l'infobulle
			$$el = $table;
			$table->{offsetx} = $offsetx;
			$table->{offsety} = $offsety;
			# $widget->drag_begin (Gtk2::TargetList->new(TARGET), 'move', 1, $event);
#$widget->get_window->set_cursor(Gtk2::Gdk::Cursor->new ('fleur'));
			# print $table->{item}->get_nom."\n";
			return;
    }
  }
	return Glib::TRUE;
}

#my $nb = 0;

sub _mouse_motion {
	my ($widget, $event, $el) = @_;
#	print "$nb\n";
#	$nb++;
	return unless ($$el);
	my ($x, $y) = $event->get_coords;
	$$el->{posx} = $x - $$el->{offsetx};
	$$el->{posy} = $y - $$el->{offsety};
	$$el->{item}->on_SchemaHelico_drag(_pos_calc($$el->{posx}, $$el->{posy},$$el->{surface} ));
	update;
	return Glib::TRUE;
}

sub _button_release {
	my ($widget, $event, $el) = @_;
	return unless ($$el);
	my ($x, $y) = $event->get_coords;
#$widget->get_window->set_cursor(undef);
	$$el->{posx} = $x - $$el->{offsetx};
	$$el->{posy} = $y - $$el->{offsety};
	# print "drag received $x $y ok\n";
	update;
		$$el = undef;
	return Glib::TRUE;
}
=pod
sub _drag_begin {
	my ($widget, $context, $el) = @_;
	my ($x, $y) = $widget->get_pointer;
	print "drag begin\n";

	while( my ($cle,$table) = each(%surfaces) ) {
    #si la souris pointe sur l'image associée
    my $rect = Gtk2::Gdk::Rectangle->new($table->{posx}, $table->{posy}, $table->{surface}->get_width, $table->{surface}->get_height);
    if (Gtk2::Gdk::Region->rectangle($rect)->point_in($x, $y) == Glib::TRUE) {
      #affichage du nom de l'item dans l'infobulle
			$$el = $table;
			print $table->{item}->get_nom."\n";
			return;
    }
  }
	# $context->finish(Glib::TRUE, Glib::FALSE, 0);

}

sub _drag_get {
	my ($widget, $context, $selection, $target_id, $etime, $el) = @_;


}

sub _drag_received {
	my ($widget, $context, $x, $y, $selection, $info, $etime, $el) = @_;
	# my ( $x, $y) = _calc_pos ($x, $y, $surface->get_width(), $surface->get_height());
      #ajout dans la base des surfaces à dessiner
	$$el->{posx} = $x;
	$$el->{posy} = $y;
	print "drag received $x $y ok\n";
	update;
      # $surfaces{$item} = {surface => $surface, posx => $x, posy => $y, item => $item};
	$context->finish(Glib::TRUE, Glib::FALSE, $etime) ;
}
use Data::Dumper;
sub _drag_drop {
	my ($widget, $context, $x, $y, $etime, $el) = @_;
	print "drop\n";
	print Dumper($el);
	$$el->{posx} = $x;
	$$el->{posy} = $y;
	print "drag received $x $y ok\n";
	update;
	$context->finish(Glib::TRUE, Glib::FALSE, $etime) ;
	return Glib::TRUE;
}
=cut

1;

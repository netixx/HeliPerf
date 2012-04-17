package mainWin::widgets::GrapheCentrage;
#TODO: ne pas faire set_is_good
use strict;
use utf8;


=pod
S'occupe d'afficher le graphique masse en fonction de la masse,


init($drawingarea) : à l'issue, le module travaillera sur le GtkDrawingArea donné en paramètre
new : efface tout, crée une ligne totale.
set_limite_centrage_coords($graphcoorda) : les limites imposées par le constructeur sont stocké dans le tableau référencé par le paramètre
set_total ($total) : mise à jour de la masse et bras total
update : synchronisation des données avec le dessin visible par the user (doit être appelée après l'appel des deux fonctions précédentes)

=cut

use Graph2D;
use DrawingArea;
use CairoBuffer;

#Taille minimale (le graphique est redimensionnable
use constant GRAPH_WIDTH  => 100;
use constant GRAPH_HEIGHT => 100;

#Noms à mettre sur les axes
use constant GRAPH_LBL_X  => "Centrage (mm)";
use constant GRAPH_LBL_Y  => "Masse totale (kg)";

#Abscisse, ordonné à l'origine
#use constant GRAPH_MIN_X => 4100;
#use constant GRAPH_MIN_Y => 1200;

#coordoonnées max visibles
#use constant GRAPH_MAX_X => 4700;
#use constant GRAPH_MAX_Y => 3000;

#use constant MARGE => 50;
use constant MARGE_RATIO => .1;

#épaisseur de la ligne lors du tracé des limites fournies par le constructeur
use constant GRAPH_LINE_WIDTH => 1.;

use constant GRAPH_COULEUR_POINT => (17/256, 21/256, 131/256);
use constant GRAPH_COULEUR_LIGNE => (40/256, 119/256, 37/256);

#tableau des coordonnées imposés par le constructeur
my $graphcoord = [[0, 0]];

my $points;
# my $id_max_carburant;

#objet Graph2D
my $graph2D;
#objet DrawingArea
my $oDrawingArea;


my $oBufferGraph2D;


#masse et bras total
# my @point;
#my $masse = 0;
#my $bras = 0;
#si tout va bien man au niveau masse et bras par rapport au limites ouais gros
#my $is_good = 0;

#GdkRegion pour calculer si un point est à l'intérieur ou à l'extérieur (utile pour calculer is_good)
#vaut undef si erreur avec graphcoord (cf set_limite_centrage_coords)
#my $region;

sub init {
  my $area = shift;  
  
  #taille minimale
  $area->set_size_request(GRAPH_WIDTH, GRAPH_HEIGHT);  
  #_draw_on_buffer pour le dessin, _on_configure à chaque redimensionnement
  $oDrawingArea = DrawingArea->new($area, \&_draw_on_buffer, \&_on_configure, GRAPH_WIDTH, GRAPH_HEIGHT);

  $oBufferGraph2D = CairoBuffer->new(GRAPH_WIDTH, GRAPH_HEIGHT);
  $graph2D = Graph2D->new($oDrawingArea->cr, GRAPH_WIDTH,  GRAPH_HEIGHT,
    0, 0, 
    1, 1,
    GRAPH_LBL_X, GRAPH_LBL_Y);    

  #Affiche les infobulles
  $area->set_has_tooltip(Glib::TRUE);
  $area->signal_connect( query_tooltip => \&_query_tool_tip );
}



sub set_limite_centrage_coords {
  #my $tab = shift;
  #taille du tableau
  #my $n = scalar(@$tab);
  $graphcoord = shift;
  my ($minx, $miny) = @{$graphcoord->[0]};
  my ($maxx, $maxy) = ($minx, $miny);
  
  foreach my $point (@$graphcoord) {
    my ($x, $y) = @$point;
    
    if ($x < $minx) {
      $minx = $x;
    }
    elsif ($x > $maxx) {
      $maxx = $x;
    }
    
    if ($y < $miny) {
      $miny = $y;
    }
    elsif ($y > $maxy) {
      $maxy = $y;
    }
  }
  
  my $offx = MARGE_RATIO * ($maxx - $minx);
  my $offy = MARGE_RATIO * ($maxy - $miny);
  $graph2D->set_cadre($minx - $offx, $miny - $offy, $maxx + $offx, $maxy + $offy);
  $oBufferGraph2D->clear();
  $graph2D->draw;
  
  
=pod
  #On vérifie qu'on nous a pas berné avec un tableau vide ou presque (3 minimum pour définir une sruface
  if ($n >= 3) {
    $graphcoord = $tab;
    #region délimitée par les impératifs du constructeurs
    #ca bug si le tableau n'a qu'un seul élément 
    #flattening the array pour utiliser  Gtk2::Gdk::Region->polygon
    my @ordered = map { @$_ } @$graphcoord;    
    $region = Gtk2::Gdk::Region->polygon (\@ordered, 'winding-rule');
    #est ce que tout va bien et oh
    $is_good = $region->point_in($bras, $masse);
  }  
  else {
    GenericWin::erreur_msg("Coordonnées centrage et masse constructeurs icomplètes : $n point seulement");
    $region = undef;
    #Centrage KO 
    $is_good = 0;
  }
=cut
  
}

#sub set_is_good {
  #if (shift) {
    ##On est bien dans les limites imposées par le constructeur
    #$oDrawingArea->area->set_tooltip_text('Centrage ok');
  #}
  #else
  #{
    ##on ne l'est pas
    #$oDrawingArea->area->set_tooltip_text('Centrage KO');
  #}
#}

sub set_points {
  $points = shift;
}

# sub set_bras_masse {
  # @point = @_;
# }

# sub set_liste_carburant {
  # my $carbliste = shift->get_items;
  # $points = map {[ $_->get_bras_masse ]} $carbliste;
# }

# sub set_id_max_carburant {
  # $id_max_carburant = shift;
# }


=pod
Prends en paramètre un objet total implémentant les méthodes
$total->get_masse : renvoie la masse totale
$total->get_bras  : renvoie le bras de levier total
=cut
=pod
sub set_total {
  my $total = shift;
  $masse = $total->get_masse ;
  $bras  = $total->get_bras  ;
  
  #$region peut ne pas être défini en cas d'erreur (cf graphcoord)
  if (defined($region)) {
    $is_good = $region->point_in($bras, $masse);
  }
  else {
    #is_good = false
    $is_good = 0;
  } 
  
  
  if ($is_good) {
    #On est bien dans les limites imposées par le constructeur
    $oDrawingArea->area->set_tooltip_text('Centrage ok');
  }
  else
  {
    #on ne l'est pas
    $oDrawingArea->area->set_tooltip_text('Centrage KO');
  }
}
=cut


=pod
Mets à jour le dessin. Doit être appelé après set_total ou set_limite_centrage_coords
=cut
sub update {
  $oDrawingArea->update;
}

#si on est dans la bonne zone du centrage
#sub is_good {
#  return $is_good;
#}

sub _on_configure {
  my ( $neww, $newh) = @_;
  
  #redimensionnage de la surface en cache : 
  $oDrawingArea->create_new_cr($neww, $newh);
  $oBufferGraph2D->create_new_cr($neww, $newh);
  
  #syncrho avec graph2D
  $graph2D->set_size($neww,$newh);
  $graph2D->set_cr($oBufferGraph2D->cr);
  $graph2D->draw;
  $oDrawingArea->draw;
}

#dessin du graph
sub _draw_on_buffer {  
  #on se fait pas chier : graph2D s'occupe d'afficher les axes et tout le bordel

#  $graph2D->draw;
#  return; 

  $oDrawingArea->clear();
  my $drcr = $oDrawingArea->cr;  
  $oBufferGraph2D->draw_to($drcr);
  
  #s'il n'y a pas de pb avec les graphcoord (cf set_limite_centrage_coords
  #if (defined($region))
  {
    #Il s'agirait de dessiner en rouge les limites imposées par le constructeur
    $drcr->set_line_width(GRAPH_LINE_WIDTH);
    $drcr->set_source_rgb(1.,0.,0.);
    
    $drcr->move_to($graph2D->vir_coord_real(@{$graphcoord->[-1]}));
    foreach  ( @$graphcoord ) { 
      $drcr->line_to($graph2D->vir_coord_real(@$_));
    }

    $drcr->stroke;
    #c'est fait. Ouf !
  }
  
  #dessin du point total sur le graphe
 
  
  if ($#$points >= 0) {
    $drcr->set_source_rgb(GRAPH_COULEUR_LIGNE);
    $drcr->move_to($graph2D->vir_coord_real(@{$points->[0]}));
    

    foreach my $point (@$points) { 
      $drcr->line_to($graph2D->vir_coord_real(@$point));
    }
    
    $drcr->stroke;
    $drcr->set_line_width(GRAPH_LINE_WIDTH*2);
    $drcr->set_source_rgb(GRAPH_COULEUR_POINT);

    $graph2D->set_cr($drcr);
    $graph2D->draw_point(@{$points->[-1]});
    $graph2D->set_cr($oBufferGraph2D->cr);
  }
  
  
}

sub export_pdf {
  my $path = shift;
  my $cr = $graph2D->cr();
  my $surfpdf = Cairo::PdfSurface->create($path,$graph2D->get_width(),$graph2D->get_height());
  my $crpdf = Cairo::Context->create ($surfpdf);
  $crpdf->set_source_surface($cr->get_target, 0., 0.);
  $crpdf->paint;
}

sub _query_tool_tip {
  my ($widget, $x, $y, $keybord_mode, $tooltip) = @_;
  
  my ($vx, $vy) = $graph2D->real_coord_vir($x, $y);
  my ($sx, $sy) = (int $vx, int $vy);
  $tooltip->set_text("($sx mm, $sy kg)");

  return Glib::TRUE;
}
1;
__END__


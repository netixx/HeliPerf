package Graph2D;
#TODO commenter, mettre les  noms sur les axes et les valeurs
#TODO ne pas recalculer bottom_right, top_left à chaque fois

=pod
****CLASSE Graph2D*****
Outil permettant d'afficher un graphique sur un contexte cairo

=cut

use strict;

use Cairo;

#Marges pour les axes
use constant X_MIN => 20;
use constant Y_MIN => 10;

#Pas du quadrillage
#use constant PAS => 20;

#nb de lignes et de colonnes du quadrillage
use constant NBDIVX => 20;
use constant NBDIVY => 10;

#Taille en pixel d'un point (cf draw_point)
use constant TAILLE_POINT => 5;

=pod
Constructeur
new($cr, $width, $height, $xmin, $ymin, $xmax, $ymax, $labelx, $labely)

$cr : contexte cairo
$width : largeur à occuper sur le contexte cr
$height : hauteur à occuper sur le contexte cr
$xmin : abscisse x à l'origine (virtuelle)
$xmax : abscisse x max affiché (virtuelle)
$labelx : Nom de l'axe à afficher
=cut
sub new {
  my ($class, $cr, $width, $height, $xmin, $ymin, $xmax, $ymax, $labelx, $labely ) = @_;
  
  my $this = {_cr => $cr, _width => $width, _height => $height,
                    _xmin => $xmin, _ymin => $ymin,
                    _xmax => $xmax, _ymax => $ymax,
                    _labelx => $labelx, _labely => $labely};
  
  return bless($this, $class);
}

sub get_width {
  return shift->{_width};
}

sub get_height {
  return shift->{_height};
}

sub set_cadre {
  my ($this, $xmin, $ymin, $xmax, $ymax) = @_;
  $this->{_xmin} = $xmin;
  $this->{_xmax} = $xmax;
  $this->{_ymin} = $ymin;
  $this->{_ymax} = $ymax;
}

sub set_size {
  my ($this, $width,$height) = @_;
  $this->{_width } = $width ;
  $this->{_height} = $height;
}

sub set_cr {
  my ($this, $cr) = @_;
  $this->{_cr} = $cr;
}


=pod
Transforme des coordonnées virtuelles (entre xmin et xmax) en coordonnées réelles (si on veut directement dessiner sur cr)
vir_coord_real ($vx, $vy)
=cut
sub vir_coord_real {
  my ($this, $x, $y) = @_;
  
  my $rx =  (($x - $this->{_xmin})*( $this->{_width } - 2*X_MIN)) / ($this->{_xmax}-$this->{_xmin});
  my $ry =  (($y - $this->{_ymin})*( $this->{_height} - 2*Y_MIN)) / ($this->{_ymax}-$this->{_ymin});
  
  $ry = $this->{_height} - $ry - Y_MIN;
  $rx = $rx + X_MIN;

  return ($rx,$ry);
}

sub real_coord_vir {
  my ($this, $x, $y) = @_;
  
  my $vx = $x - X_MIN;
  my $vy = $this->{_height} - $y - Y_MIN;

  $vx =  (($x * ($this->{_xmax} - $this->{_xmin})) / ( $this->{_width } - 2*X_MIN)) + $this->{_xmin};
  $vy =  (($y * ($this->{_ymax} - $this->{_ymin})) / ( $this->{_height} - 2*Y_MIN)) + $this->{_ymin};

  return ($vx,$vy);
}

sub bottom {
  return shift->{_height} - Y_MIN;
}

sub top {
  return Y_MIN;
}

sub left {
  return X_MIN;
}

sub right {
  return shift->{_width} - X_MIN;
}

sub top_left {
  my $this = shift;
  return ($this->left, $this->top);
}

sub top_right {
  my $this = shift;
  return ($this->right, $this->top);
}

sub bottom_left {
  my $this = shift;
  return ($this->left, $this->bottom);
}

sub bottom_right {
  my $this = shift;
  return ($this->right, $this->bottom);
}

sub cr {
  return shift->{_cr};
}



sub _draw_axes {
  my $this = shift;
  my $cr = $this->{_cr};
  
  my @top_left = $this->top_left;
  my @origine  = $this->bottom_left;
  my @bottom_right = $this->bottom_right;
  
  #Première flèche en haut et le texte
  my ($x,$y) = @top_left;
  $cr->move_to($x - (X_MIN / 2), $y + (Y_MIN / 2));
  $cr->line_to(@top_left);

  #label y placé
  $cr->rel_line_to(X_MIN/2, Y_MIN / 2);
  $cr->show_text($this->{_labely});
 
  #Deuxième flèche x et la legende
  ($x,$y) = @bottom_right;
  $cr->move_to($x - (X_MIN / 2), $y - (Y_MIN / 2));
  $cr->line_to(@bottom_right);
  $cr->rel_line_to(- (X_MIN/2), Y_MIN / 2);

  #label x placé
  my $extent = $cr->text_extents($this->{_labelx});
  $cr->rel_move_to(-$extent->{width}, - $extent->{height});
  $cr->show_text($this->{_labelx});
  
  $cr->move_to(@top_left);
  $cr->line_to(@origine);
  $cr->line_to(@bottom_right);
  
  $cr->set_line_width(1.0);
  $cr->set_source_rgb (0., 0., 0.);
  $cr->stroke;  
}

sub _draw_quadrillage {
  my $this = shift;
  my @origine = $this->bottom_left;
  my $cr = $this->{_cr};
   
  #for( my $x=X_MIN; $x < $this->{_width} - X_MIN; $x += PAS ) {
    #$cr->move_to($x , Y_MIN);
    #$cr->line_to($x , $this->{_height} - Y_MIN);
  #}
  #
  #for( my $y=$this->{_height} - Y_MIN; $y > Y_MIN ; $y -= PAS ) {
    #$cr->move_to(X_MIN , $y);
    #$cr->line_to($this->{_width} - X_MIN , $y);
  #}
  my $pas = ($this->{_width} - 2 * X_MIN) / NBDIVX;
  
  for( my $x=X_MIN; $x < $this->{_width} - X_MIN; $x += $pas ) {
    $cr->move_to($x , Y_MIN);
    $cr->line_to($x , $this->{_height} - Y_MIN);
  }
  
  $pas = ($this->{_height} - 2 * Y_MIN) / NBDIVY;
  
  for( my $y=$this->{_height} - Y_MIN; $y > Y_MIN ; $y -= $pas) {
    $cr->move_to(X_MIN , $y);
    $cr->line_to($this->{_width} - X_MIN , $y);
  }

  $cr->set_line_width(0.5);
  $cr->set_source_rgb (0., 0., 0.);
  $cr->stroke;
  
}

sub draw {
  my $this = shift;
  $this->cr->set_line_cap('butt');
  $this->cr->set_line_join('miter');
  # $this->_erase;
  $this->_draw_quadrillage;
  $this->_draw_axes; 

}




#dessine un point aux coordonnée virtuelles
sub draw_point {
  my ($this, $vx, $vy) = @_;
  my $cr = $this->cr;
  
  my ($x, $y) = $this->vir_coord_real($vx, $vy);
  
  if ($vx > $this->{_xmax}) {
    if ($vy > $this->{_ymax}) {
      #on dessine une flèche en haut à droite
      $this->_draw_top_right_arrow;
    }
    elsif ($vy < $this->{_ymin}) {
      #on dessine une flèche en bas à droite
      $this->_draw_bottom_right_arrow;
    }
    else {
      #on dessine une flèche à droite
      $this->_draw_right_arrow($y);      
    }    
  }
  elsif ($vx < $this->{_xmin}) {
    if ($vy > $this->{_ymax}) {
      #on dessine une flèche en haut à gauche
      $this->_draw_top_left_arrow;
    }
    elsif ($vy < $this->{_ymin}) {
      #on dessine une flèche en bas à gauche
       $this->_draw_bottom_left_arrow;
    }
    else {
      #on dessine une flèche à gauche
      $this->_draw_left_arrow($y);         
    }
  }
  else {
    if ($vy > $this->{_ymax}) {
      #on dessine une flèche en haut
      $this->_draw_top_arrow($x);
    }
    elsif ($vy < $this->{_ymin}) {
      #on dessine une flèche en bas
      $this->_draw_bottom_arrow($x);
    }
    else {
      #on dessine un point
      $this->_draw_point($x, $y);         
    }
  } 

}

=pod
Méthodes utilisées par draw_point
=cut
sub _draw_top_right_arrow {
  my $this = shift;
  my $cr = $this->cr;
  
  my ($x, $y) = $this->top_right;
      
  $cr->move_to($x - TAILLE_POINT / 2, $y);
  $cr->rel_line_to(TAILLE_POINT / 2, 0);
  $cr->rel_line_to(0,TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(- TAILLE_POINT, TAILLE_POINT);
  $cr->stroke;
}

sub _draw_bottom_right_arrow {
  my $this = shift;
  my $cr = $this->cr;
  
  my ($x, $y) = $this->bottom_right;
      
  $cr->move_to($x - TAILLE_POINT / 2, $y);
  $cr->rel_line_to(TAILLE_POINT / 2, 0);
  $cr->rel_line_to(0,- TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(- TAILLE_POINT, - TAILLE_POINT);
  $cr->stroke;
}

sub _draw_bottom_left_arrow {
  my $this = shift;
  my $cr = $this->cr;
  
  my ($x, $y) = $this->bottom_left;
      
  $cr->move_to($x + TAILLE_POINT / 2, $y);
  $cr->rel_line_to(- TAILLE_POINT / 2, 0);
  $cr->rel_line_to(0,- TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to( TAILLE_POINT, - TAILLE_POINT);
  $cr->stroke;
}

sub _draw_top_left_arrow {
  my $this = shift;
  my $cr = $this->cr;
  
  my ($x, $y) = $this->top_left;
      
  $cr->move_to($x + TAILLE_POINT / 2, $y);
  $cr->rel_line_to(- TAILLE_POINT / 2, 0);
  $cr->rel_line_to(0, TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to( TAILLE_POINT, TAILLE_POINT);
  $cr->stroke;
}

sub _draw_right_arrow {
  my ($this, $y) = @_;
  my $cr = $this->cr;
  
  #on dessine une flèche à droite
  my $x = $this->right;
  
  $cr->move_to($x - TAILLE_POINT / 2, $y -  TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2,  TAILLE_POINT / 2);
  $cr->rel_line_to(- TAILLE_POINT / 2, TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(- TAILLE_POINT, 0);
  $cr->stroke;
}

sub _draw_left_arrow {
  # GenericWin::erreur_msg("left_arrow");
  my ($this, $y) = @_;
  my $cr = $this->cr;
  
  #on dessine une flèche à gauche
  my $x = $this->left;
  
  $cr->move_to($x + TAILLE_POINT / 2, $y -  TAILLE_POINT / 2);
  $cr->rel_line_to(- TAILLE_POINT / 2,  TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2, TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(TAILLE_POINT, 0);
  $cr->stroke;
}

sub _draw_top_arrow {
  my ($this, $x) = @_;
  my $cr = $this->cr;
  
  #on dessine une flèche en haut
  my $y = $this->top;
  
  $cr->move_to($x - TAILLE_POINT / 2, $y +  TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2, - TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2, TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(0, TAILLE_POINT);
  $cr->stroke;
}

sub _draw_bottom_arrow {
  my ($this, $x) = @_;
  my $cr = $this->cr;
  
  #on dessine une flèche en bas
  my $y = $this->bottom;
  
  $cr->move_to($x - TAILLE_POINT / 2, $y -  TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2, TAILLE_POINT / 2);
  $cr->rel_line_to(TAILLE_POINT / 2, - TAILLE_POINT / 2);
  $cr->stroke;
  
  $cr->move_to($x, $y);
  $cr->rel_line_to(0, - TAILLE_POINT);
  $cr->stroke;
}

sub _draw_point {
  my ($this, $x, $y) = @_;
  my $cr = $this->cr;
  
  $cr->move_to($x - TAILLE_POINT, $y);
  $cr->line_to($x + TAILLE_POINT, $y);
  
  $cr->move_to($x, $y - TAILLE_POINT);
  $cr->line_to($x, $y + TAILLE_POINT);
  
  $cr->stroke;
}

1;

package DrawingArea;
#TODO: documenter
use Cairo;
use Gtk2;

#TODO: ne dessiner que la partie à redessiner dans expose-event
=pod
****CLASSE DrawingArea*****
facilite la gestion d'une drawingarea
S'occupe de créer automatiquement une surface en buffer, de la redessiner pour les expose-event et les configure event

DrawingArea->new($area; $draw_func, $on_conf_func, $w, $h)

  $area : GtkDrawingArea à gérer
  $draw_func : fonction appelée pour dessiner sur la surface en cache ($draw_func->($cr) ou $cr est le contexte Cairo de la surface)
  $on_conf_func : appelée lors de l'événement configure, en paramètres on_conf_func($new_width, $new_height), la surface en cache n'est pas
    automatiquement redimensionnée
  $w, $h : taille initiale souhaitée pour la surface en cache

create_new_cr($w ,$h) : crée un nouveau contexte cairo associé à une surface de dimension $w * $h
update : redessin du widget à l'écran


=cut

use base CairoBuffer;

sub new {
  my ($class, $area, $draw_func, $on_conf_func, $w, $h) = @_;
  my $this = CairoBuffer->new($w, $h);
  $this-> { _AREA} = $area;
  $this->{_DRAW_FUNC} = $draw_func;
  $this->{_CONF_FUNC} = $on_conf_func ;
  bless($this, $class);

  $area->realize;
  
  #crée la surface en cache
#  $this->create_new_cr($w, $h);  
    
  $area->add_events ([qw/exposure-mask/]);
# Signals used to handle backing pixmap
 #l'objet est passé en paramètre supplémentaire aux callbacks
  $area->signal_connect( expose_event    => \&_expose_event,    $this );
  $area->signal_connect( configure_event => \&_configure_event, $this ); 
  #crée l'area->window je crois (cf doc Gtk2)

  


  
  return $this;
}

sub area {
  return shift->{_AREA};
}


#dessin sur la surface en cache
sub draw {
  my $this = shift;
  my $cr = $this->cr;
  
  $this->clear();
  $this->{_DRAW_FUNC}->($cr);
}

sub on_conf_func {
  my $this = shift;
  $this->{_CONF_FUNC}->(@_);
}

#mise à jour graphique du widget
sub update {
  $this = shift;
  $this->draw;
  #without this line the screen won't be updated until a screen action
  $this->area->queue_draw;
}


#Autre nom de _create_cr
# sub create_new_cr {
  # my $this = shift;
  # $this->_create_cr(@_);
# }

##########################################
# Create a new backing pixmap of the appropriate size
sub _configure_event {
  my $widget = shift;    # GtkWidget         *widget
  my $event  = shift;    # GdkEventConfigure *event
  my $this   = shift;  
 
  my $w = $widget->allocation->width;
  my $h = $widget->allocation->height;

  #on appelle la fonction utilisateur
  $this->on_conf_func($w, $h);
#  $this->draw;

  return Glib::TRUE;
}

##########################################
# Redraw the screen from the backing pixmap
#TODO: ne redessiner que la partie utile
sub _expose_event {
  my $widget = shift;    # GtkWidget      *widget
  my $event  = shift;    # GdkEventExpose *event
  my $this   = shift;

  #Copie la surface en cache sur l'écran
#  my $cr = Gtk2::Gdk::Cairo::Context->create ($this->area->window);
#  $cr->set_source_surface($this->cr->get_target, 0., 0.);
#  $cr->paint;
  $this->draw_to(Gtk2::Gdk::Cairo::Context->create ($this->area->window));
  return Glib::FALSE;
}

1;

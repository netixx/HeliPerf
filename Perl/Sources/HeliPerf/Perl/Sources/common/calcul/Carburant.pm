package calcul::Carburant;

use strict;


#renvoie l'index dans liste du dernier carburant le plus leger, le bras et la masse du volume (interpolation liénaire)
#DEPRECATED
sub first_idx_bras {
  my ($carburant, $masse) = @_;
 
  my $idx = int($masse / $carburant->get_pas);
  my $items = $carburant->get_items;
  
  my $ratio = ($masse - $items->[$idx]->get_masse) / ($items->[$idx+1]->get_masse - $items->[$idx]->get_masse);
  my $bras  = $items->[$idx]->get_bras  + $ratio * ($items->[$idx+1]->get_bras  - $items->[$idx]->get_bras );
  
  return ($idx, $bras);
}

#renvoie la liste de carburant plus léger
#et le premier plus lour 
sub get_plus_leger {
	my ($liste_carburant, $masse) = @_;

	my $items = $liste_carburant->get_items;
	my $pas = $liste_carburant->get_pas;
	my $idx=0;

	if ($pas) {
		$idx = int($masse / $pas);
	}
	else {
#		for ($idx = 0; $idx < $#$items && $items->[$idx]->get_masse < $masse; $idx++) {}
		while ($idx < $#$items && $items->[$idx]->get_masse < $masse) {$idx++;}
	}

	#on renvoie au moins 2 items
	$idx++ unless ($idx);

	return (@$items)[0 .. $idx];
}

#le bras  du volume (interpolation liénaire)
sub get_bras_interpol {
	my ($carb1, $carb2, $masse) = @_;
	my $ratio = ($masse - $carb1->get_masse) / ($carb2->get_masse - $carb1->get_masse);
	my $bras  = $carb1->get_bras  + $ratio * ($carb2->get_bras  - $carb1->get_bras );
	return $bras;
}

#renvoie le carburant maximal qu'on peut mettre
#centragecheck : cf calcul::Centrage
#carburant : liste de carburant (models::Carburant)
#bras, masse : bras et masse total sans carburant
sub max_carburant {
  my ($centragecheck, $carburant, $bras, $masse) = @_;
  my $carbs = $carburant->get_items;
  
  my $i = 1;
  my $n = $#$carbs;

  while ($i <= $n && $centragecheck->is_good(calcul::Centrage::ajoute_masse($bras, $masse, $carbs->[$i]->get_bras_masse))) { 
    # print "ok\n";
    $i++;    
  }
  
  # print ' '.$total->get_bras."\n";
  return $carbs->[$i-1];  
}



1;

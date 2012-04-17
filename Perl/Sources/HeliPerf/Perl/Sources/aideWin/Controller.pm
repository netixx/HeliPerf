package aideWin::Controller;

use strict;

use utf8;

use GenericWin;

sub aidewin_button {
    my $content = [['aide','bouton_titre'],['aide','bouton_description'],['aide','bouton_message']];
    GenericWin::info($content);
}

sub aideWin_editeur {
    my $content = [['aide','editeur_titre'],['aide','editeur_description'],['aide','editeur_message']];
    GenericWin::info($content);
}
1;
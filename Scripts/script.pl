use strict;
use warnings;


my $match_str = 'GenericWin::ouinon\(.+\{$1\}\{$2\},.+\{$3\}\{$4\}\)';
my $replace_str = 'GenericWin::ouinon\(\[\[\'$1\',\'$2\'\],\[\'$3\',\'$4\'\]\])';

use constant RECURSIF => 1;
use constant START_DIR => '.';

my $debug = 0;


my @lib_paths = ('.');

if ($debug){
    print "U3_DEVICE_PATH is u3_drive\n";
    print "$_ is a LIB path\n" for (@lib_paths);
}

my @dirs = ();
sub rec_trait {
  my @dirs = @_;
  my $dir = join('/', @dirs);

 #print "[$dir]\n";

  -d $dir or die "HALT: $_ not found ($!)\n";

  opendir THEDIR, $dir or die "HALT: Can't open $dir ($!)\n";
  my @lib_files = readdir THEDIR or die "HALT: Can't read $dir ($!)\n";
  close THEDIR;

  for my $file (@lib_files){

      if ($file eq '.' || $file eq '..' || $file eq 'script.pl') { next; }

      my $lib_file = "$dir/$file";

      if (-d $lib_file) {
        #récursif ?
         rec_trait(@dirs, $file) if (RECURSIF);

      }

      elsif ($file =~ /(.pm|pl)$/) {


        open THEFILE,"<$lib_file"  or die "HALT: Can't open $lib_file ($!)\n";
        my @lignes = <THEFILE>;
        close THEFILE;
       # print "$file\n";
        my $str = join('::', @dirs);
        #chain à remplacer
        #map  { my $s = s/$match_str/$replace_str/g; print "$lib_file  $_" if $s;} @lignes;
        # map  { my $s  =s/GenericWin::erreur_end\(.+\{(.+)\}\{(.+)\},.+\{(.+)\}\{(.+)\}\)/GenericWin::erreur_end\(\[\[\'\1\',\'\2\'\],\[\'\3\',\'\4\'\]\])/g; print "$lib_file  $_" if $s;} @lignes;
     map  { my $s  =s/GenericWin::erreur_msg\(\[\[\'(.+)',\'(.+)'\]\)/GenericWin::erreur_msg\(\[\[\'\1\',\'\2\'\]\\])/g; print "$lib_file  $_" if $s;} @lignes;
        open THEFILE,">$lib_file"  or die "HALT: Can't open $lib_file ($!)\n";
        print THEFILE @lignes;
        close THEFILE;
      }
  }

}

rec_trait START_DIR;

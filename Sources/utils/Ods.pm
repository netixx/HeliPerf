package Ods;
#TODO: pouvoir choisir le type des colonnes (texte ou numérique)
=pod
exporte un tableau à 2 entrées dans un fichier fichier Ods, en supposant qu'on s'est placé dans le bon
répertoire Ods

export($array, $filename) : exporte le tableau $array à deux dimensions dans le fichier $filename
  renvoie true si tout va bien, false sinon
erreur : renvoie le dernier message d'erreur
=cut

use strict;
use File::Find;

use IO::Compress::Zip qw(zip $ZipError) ;
# zip 'img\EC 135_mini.png'=> 'img.zip' or die "zip failed: $ZipError\n";

my $errmsg;

sub get_erreur {
  return $errmsg;
}

sub export {
  my ($array, $filename) = @_;
  
  if (!open(FIC,">:utf8",'content.xml')) {
    $errmsg = "$!";
    #return false
    return 0;
  }

  
  print FIC <<'HTML';
   <office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:presentation="urn:oasis:names:tc:opendocument:xmlns:presentation:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" office:version="1.2" grddl:transformation="http://docs.oasis-open.org/office/1.2/xslt/odf2rdf.xsl">
<office:scripts/>
<office:font-face-decls>
<style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="swiss" style:font-pitch="variable"/>
<style:font-face style:name="Lucida Sans Unicode" svg:font-family="'Lucida Sans Unicode'" style:font-family-generic="system" style:font-pitch="variable"/>
<style:font-face style:name="Mangal" svg:font-family="Mangal" style:font-family-generic="system" style:font-pitch="variable"/>
<style:font-face style:name="Microsoft YaHei" svg:font-family="'Microsoft YaHei'" style:font-family-generic="system" style:font-pitch="variable"/>
<style:font-face style:name="Tahoma" svg:font-family="Tahoma" style:font-family-generic="system" style:font-pitch="variable"/>
</office:font-face-decls>
<office:automatic-styles>
<style:style style:name="co1" style:family="table-column">
<style:table-column-properties fo:break-before="auto" style:column-width="2.267cm"/>
</style:style>
<style:style style:name="ro1" style:family="table-row">
<style:table-row-properties style:row-height="0.453cm" fo:break-before="auto" style:use-optimal-row-height="true"/>
</style:style>
<style:style style:name="ta1" style:family="table" style:master-page-name="Default">
<style:table-properties table:display="true" style:writing-mode="lr-tb"/>
</style:style>
</office:automatic-styles>
<office:body>


<office:spreadsheet>
<table:table table:name="Feuille1" table:style-name="ta1" table:print="false">
HTML

  #nb de colonne
  my $n_colonnes = @{$array->[0]};
  print FIC <<HTML;
  <table:table-column table:style-name="co1" table:number-columns-repeated="$n_colonnes" table:default-cell-style-name="Default"/>
HTML

  foreach my $ligne (@$array) {
    print FIC '<table:table-row table:style-name="ro1">';
    
    foreach my $valeur (@$ligne) {
      print FIC <<HTML;
<table:table-cell office:value-type="string">
<text:p>$valeur</text:p>
</table:table-cell>
HTML
    }
    print FIC '</table:table-row>';
  }
# <table:table-row table:style-name="ro1">
# <table:table-cell office:value-type="string">
# <text:p>Passager</text:p>
# </table:table-cell>
# <table:table-cell office:value-type="float" office:value="90">
# <text:p>90</text:p>
# </table:table-cell>
# <table:table-cell office:value-type="float" office:value="23333">
# <text:p>23333</text:p>
# </table:table-cell>
# <table:table-cell table:number-columns-repeated="2"/>
# </table:table-row>
# HTML

print FIC <<'HTML';
</table:table>
<table:table table:name="Feuille2" table:style-name="ta1" table:print="false">
<table:table-column table:style-name="co1" table:default-cell-style-name="Default"/>
<table:table-row table:style-name="ro1">
<table:table-cell/>
</table:table-row>
</table:table>
<table:table table:name="Feuille3" table:style-name="ta1" table:print="false">
<table:table-column table:style-name="co1" table:default-cell-style-name="Default"/>
<table:table-row table:style-name="ro1">
<table:table-cell/>
</table:table-row>
</table:table>
</office:spreadsheet>
</office:body>
</office:document-content>
HTML
  
  
  close FIC;
  
  my @files = ();
  
  # my $curdir = cwd;
  # chdir ($dir);
  
  find(sub { push @files, substr($File::Find::name, 2) unless -d}, '.') ;
  # print join("\n", @files);
  if (!(zip \@files => $filename)) {
    $errmsg = "Echec de la compression : $ZipError\n";
    #return false
    return 0;
  }
  
  #return true
  return 1;
}

1;
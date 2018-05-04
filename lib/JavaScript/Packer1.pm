package    # hidden from PAUSE
    JavaScript::Packer1;

use warnings;
use strict;

our $VERSION   = '0.25';
our $AUTHORITY = 'cpan:FAYLAND';

use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/js_packer/;

my (@lines);
my ($payload, $symtab, $radix, $count, $splitchar, $before, $after);
my (@alfa_values, @symbols);
my $ALPHABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
my ($decoded);

sub check_packer($) {
    my ($line) = @_;
    $before  = '';
    $after   = '';
    $decoded = '';
    if ($line =~ /eval\(function\(p,a,c,k,e,([d|r])\)\{/) {
        return 1;
    } else {
        return 0;
    }
}

sub get_table_elements($) {
    my ($line) = @_;
    $before = '';
    $after  = '';
    # caret2.js miatt
    if ($line =~ /eval\(function\(p,a,c,k,e,[d|r]\)\{.*?\}?\}?return \w+\}\('(.*?[^\\])',(\d+|\[\]),(\d+),'(.*?)'\.split\('(.*?)'\).*?\)\)/) {
        $payload = $1;
        if   ($2 eq '[]') { $radix = 62; }
        else              { $radix = $2; }
        $count     = $3;
        $symtab    = $4;
        $splitchar = $5;
        $after     = $';
        $before    = $`;
        if ($splitchar eq '\\u005e') { $splitchar = '^'; }
        return 1;
    } else {
        return 0;
    }
}

sub get_index($) {
    my ($ix) = @_;
    my @values = split('', $ix);
    my $size = @values;
    my ($idx) = grep { $alfa_values[$_] eq $values[$size - 1] } 0 .. $#alfa_values;
    if ($size == 2) { $idx += $values[0] * $radix; }
    return $idx;
}

sub do_decode(){
  my ($rest, $ix1);
  my ($one, $two, $three);
  $decoded = '';
  @alfa_values = split('', $ALPHABET);
  @symbols = split('\\'.$splitchar, $symtab);
  for(my $i = 0; $i < $#symbols;$i++){
      if($symbols[$i] eq ''){
        $symbols[$i] = $i;
      }
  }
  $rest = $payload;
  while($rest =~ /(\W+)?(\w+)(\W+)?/){
    $rest = $';
    $ix1 = 0;
    $one = $two = $three = '';
    if(defined($2)){
       $ix1 = get_index($2);
       if(defined($symbols[$ix1])){
          $two = $symbols[$ix1];
       } else{
          $two = "$2";
        }
    }
    if(defined($1)){$one = $1;}
    if(defined($3)){$three = $3;}
    $decoded .= "$one$two$three";
  } # while
  $decoded .= $rest;   
}


sub js_packer {
    my ($js_source_code) = @_;
    if (check_packer($js_source_code)) {
        if (get_table_elements($js_source_code)) {
            do_decode();
        }
        my $retval = join('', $before, $decoded, $after);
        if ($retval eq '') {
            $retval = $js_source_code;
        }
        return $retval;
    }
    return $js_source_code;
}

1;

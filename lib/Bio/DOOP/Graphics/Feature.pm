package Bio::DOOP::Graphics::Feature;

use strict;
use warnings;
use Carp qw(cluck carp verbose);
use GD;

=head1 NAME

  Bio::DOOP::Graphics::Feature - graphical representation of the features

=head1 SYNOPSIS

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 DESCRIPTION

  This object is represent a picture that is contain all the sequence features in the subset.
  This module is enough quick to use it in your CGI scripts. You can also use it to visualize
  the subset.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=head2 create

  $pic = Bio::DOOP::Graphics::Feature->create($db,"1234");

  Create new picture. Later you can add your own graphics element to this.
  Arguments: 
  1. Bio::DOOP::DBSQL object
  2. Subset primary id.
  Return type: Bio::DOOP::Graphics::Feature

=cut

sub create {

  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $subset               = shift;

  my @seqs    = @{$subset->get_all_seqs};
  my $height  = ($#seqs+1) * 70 + 40;
  my $width   = $subset->get_cluster->get_promo_type + 20;
  my $image   = new GD::Image($width,$height); # Create the image

  $self->{IMAGE}           = $image;
  $self->{DB}              = $db;
  $self->{SEQS}            = \@seqs;
  $self->{WIDTH}           = $width;
  $self->{HEIGHT}          = $height;
  $self->{POS}             = 0;
  $self->{SUBSET_ID}       = $subset->get_id;

  # This is the map of the image. It is useful for generate html code
  #TODO Later add more types to this hash
  $self->{MAP}             = {
                                motif => [],
                                dbtss => [],
                                utr   => []
  };
  # The color map of the object
  $self->{COLOR}           = {
                                background => [200,200,200],
                                label      => [0,0,0],
                                strip      => [220,220,220],
                                utr        => [100,100,255],
                                motif      => [0,100,0],
                                tss        => [0,0,0]
  };

  bless $self;
  return($self);
}

=head2 add_color

  Add an RGB color to the specified drawing element.
  $image->add_color("background",200,200,200);
  $image->set_colors;
  The available drawing elements are the following: background, label, strip, utr, motif, tss

=cut

sub add_color {
  my $self                 = shift;
  my $code                 = shift;
  my $r                    = shift;
  my $g                    = shift;
  my $b                    = shift;
  my @color;
  @color = ($r,$g,$b);
  $self->{COLOR}->{"$code"} = \@color;
}

=head2 set_colors

  Set all the usage colors. Preveously allocate colors with add_color. Use this method only ONCE after you set
  all the colors.
  If you use it more than one, the results will be strange.

=cut

sub set_colors {
  my $self                 = shift;

  my $r;
  my $g;
  my $b;
  ($r,$g,$b) = @{$self->{COLOR}->{background}};
  $self->{IMAGE}->colorAllocate($r,$g,$b);                         # Set the background color
  ($r,$g,$b) = @{$self->{COLOR}->{label}};
  $self->{LABEL}      = $self->{IMAGE}->colorAllocate($r,$g,$b);   # Set the label color
  ($r,$g,$b) = @{$self->{COLOR}->{utr}};
  $self->{UTR}        = $self->{IMAGE}->colorAllocate($r,$g,$b);   # Set the UTR color
  ($r,$g,$b) = @{$self->{COLOR}->{motif}};
  $self->{MOTIFCOLOR} = $self->{IMAGE}->colorAllocate($r,$g,$b);   # Set the motif color
  ($r,$g,$b) = @{$self->{COLOR}->{tss}};
  $self->{TSSCOLOR}   = $self->{IMAGE}->colorAllocate($r,$g,$b);   # Set the tss color
  ($r,$g,$b) = @{$self->{COLOR}->{strip}};
  $self->{STRIP}      = $self->{IMAGE}->colorAllocate($r,$g,$b);   # Set the strip color
}

=head2 add_scale

  Draws scale on the picture

=cut

sub add_scale {
  my $self                 = shift;

  my $color = $self->{LABEL};

  # Draw the main axis
  $self->{IMAGE}->line(10,5,$self->{WIDTH}-10,5,$color);

  # Draw the scales
  my $i;
  for ($i = 20; $i < $self->{WIDTH}-10; $i += 10){
      if( ($i / 100) == int($i / 100) ) {
          $self->{IMAGE}->line($i+10,0,$i+10,10,$color);     # Big scale
          my $str = ($self->{WIDTH} - 20 - $i) * -1;   # The scale label
          my $posx = $i - (length($str)/2)*5 + 10;     # Nice label positioning
          $self->{IMAGE}->string(gdTinyFont,$posx,10,$str,$color);
      }
      else {
          $self->{IMAGE}->line($i+10,3,$i+10,7,$color); # Little scale
      }
  }

  # Draw the arrow
  my $arrow = new GD::Polygon;
  $arrow->addPt(9,5);
  $arrow->addPt(15,2);
  $arrow->addPt(15,8);
  $self->{IMAGE}->filledPolygon($arrow,$color);
}

=head2 add_bck_lines

  Draws scale lines through the whole image background

=cut

sub add_bck_lines {
  my $self                 = shift;
  my $color = $self->{STRIP};

  my $i;
  for ($i = 20; $i < $self->{WIDTH}-10; $i += 10){
          $self->{IMAGE}->line($i,0,$i,$self->{HEIGHT},$color);
      }

}

=head2 add_seq

  Draws a specified seq on the picture. This is an internal code, so do not use it directly

=cut

sub add_seq {
  my $self                 = shift;
  my $index                = shift;

  my $seq = $self->{SEQS}->[$index];
  my $len = $seq->get_length;
  my $x1  = $self->{WIDTH} - 10;
  my $x2  = $x1-$len;

  # Draw the seq line
  $self->{IMAGE}->line($x2, $index*70+40, $x1, $index*70+40, $self->{LABEL});

  # Print the seq name and the length
  my $text = $seq->get_taxon_name . " " . $len . " bp";
  $self->{IMAGE}->string(gdTinyFont, $x2, $index*70+30, $text, $self->{LABEL});

  # Draw UTR
  my $utrlen = $seq->get_utr_length;
  if ($utrlen){
      $self->{IMAGE}->filledRectangle($x1-$utrlen, $index*70+35, $x1, $index*70+45, $self->{UTR});
      $self->{IMAGE}->string(gdTinyFont, $x1-$utrlen, $index*70+36, "UTR ".$utrlen." bp", $self->{LABEL});
  }
  # Draw Features
  my @features = @{$seq->get_all_seq_features};
  my $motif_Y = $index*70 + 50;
  my $shift_factor = 0;
  my $motif_count = 0;
  for my $feat (@features){
      # Draw motifs
      if( ($feat->get_type eq "con") && ($feat->get_subsetid eq $self->{SUBSET_ID})){
if ($feat->length < 12){$shift_factor = 15 - ($shift_factor and 15)}else{$shift_factor = 0}
          my %motif_element = ($feat->get_motifid => [ $x1-$feat->get_end,
                                                       $motif_Y + $shift_factor,
                                                       $x1-$feat->get_start,
                                                       $motif_Y + $shift_factor + 5 ]);
          $self->{IMAGE}->filledRectangle($x1-$feat->get_end,
                                          $motif_Y + $shift_factor,
                                          $x1-$feat->get_start,
                                          $motif_Y + $shift_factor + 5,
                                          $self->{MOTIFCOLOR});
          $self->{IMAGE}->string(gdTinyFont, $x1-$feat->get_end, $motif_Y+$shift_factor+7, "m$motif_count", $self->{LABEL});
          push @{$self->{MAP}->{"motif"}},\%motif_element;
$motif_count++;
      }

      # Draw tss
      if( ($feat->get_type eq "tss")){
          $self->{IMAGE}->line($x1-$feat->get_start,
                               $motif_Y+20,
                               $x1-$feat->get_start-5,
                               $motif_Y+35,
                               $self->{TSSCOLOR});
          $self->{IMAGE}->line($x1-$feat->get_start-5,
                               $motif_Y+35,
                               $x1-$feat->get_start+5,
                               $motif_Y+35,
                               $self->{TSSCOLOR});
          $self->{IMAGE}->line($x1-$feat->get_start,
                               $motif_Y+20,
                               $x1-$feat->get_start+5,
                               $motif_Y+35,
                               $self->{TSSCOLOR});
      }

  }

}

=head2 add_all_seq

  Draws all seq from subset on the picture.

=cut

sub add_all_seq {
  my $self                 = shift;
  my @seqs = @{$self->{SEQS}};
  my $i;
  for($i = 0; $i < $#seqs+1; $i++){
     $self->add_seq($i);
  }
}

=head2 get_png

  open IMAGE,">picture.png";
  binmode IMAGE;
  print IMAGE $image->get_png;
  close IMAGE;

  Returns the png image. Use this when you finish the work and would like to see the results.

=cut

sub get_png {
  my $self                 = shift;
  return($self->{IMAGE}->png);
}


=head2 get_image

  Returns the drawed image pointer. Useful for add your own GD methods for uniq picture manipulating.

=cut

sub get_image {
  my $self                 = shift;
  return($self->{IMAGE});
}

=head2 get_map

  Returns a hash of arrays of hash of arrays reference that is contain the map information.
  Here is a real world example of how to handle this method:

  use Bio::DOOP::DOOP;

  $db      = Bio::DOOP::DBSQL->connect($user,$passwd,"doop-plant-1_5","localhost");
  $cluster = Bio::DOOP::Cluster->new($db,'81001110','500');
  $image   = Bio::DOOP::Graphics::Feature->create($db,$cluster);

  for $motif (@{$image->get_map->{motif}}){ # You can use 
    for $motif_id (keys %{$motif}){
       @coords = @{$$motif{$motif_id}};
       # Print out the motif primary id and the four coordinates in the picture
       #        id        x1         y1         x2         y2
       print "$motif_id $coords[0] $coords[1] $coords[2] $coords[3]\n";
    }
  }
  
  It is a little bit difficult, but if you familiar with references and hash of array, you
  will be understand.

=cut

sub get_map {
  my $self                 = shift;
  return($self->{MAP});
}

=head2 get_motif_map

  Returns only the arrayref of motif hashes

=cut

sub get_motif_map {
  my $self                 = shift;
  return($self->{MAP}->{motif});
}

=head2 get_motif_id_by_coord

  $motifi = $image->get_motif_id_by_coord(100,200);

  Maybe this is the most useful method. You can get a motif id, if you specify a coordinate of a point.
  Return type: string

=cut

sub get_motif_id_by_coord {
  my $self                 = shift;
  my $x                    = shift;
  my $y                    = shift;

  for my $motif (@{$self->get_motif_map}){ 
    for my $motif_id (keys %{$motif}){
       my @coords = @{$$motif{$motif_id}};
       if(($x > $coords[0]) && ($x < $coords[2]) &&
          ($y > $coords[1]) && ($y < $coords[3])) {
           return($motif_id);
       }
    }
  }
  return(0);
}


1;

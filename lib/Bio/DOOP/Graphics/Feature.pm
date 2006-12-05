package Bio::DOOP::Graphics::Feature;

use strict;
use warnings;
use GD;
use Bio::DOOP::DOOP;

=head1 NAME

  Bio::DOOP::Graphics::Feature - graphical representation of the features

=head1 SYNOPSIS

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

  This object is represent a picture that is contain all the sequence features in the subset.
  This module is enough quick to use it in your CGI scripts.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=head2 create

  Create new picture. Later you can add your own graphics element to this.

=cut

sub create {

  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $cluster              = shift; 

  my @seqs    = @{$cluster->get_all_seqs};
  my $height  = ($#seqs+1) * 70 + 40;
  my $width   = $cluster->get_promo_type + 20;

  my $image   = new GD::Image($width,$height); # Create the image

  $self->{IMAGE}           = $image;
  $self->{DB}              = $db;
  $self->{SEQS}            = \@seqs;
  $self->{WIDTH}           = $width;
  $self->{HEIGHT}          = $height;
  $self->{POS}             = 0;

  # This is the map of the image. It is useful for generate html code
  #TODO Later add more types to this hash
  $self->{MAP}             = {
                                motif => [],
                                dbtss => [],
                                utr   => []
  };

  bless $self;
  return($self);
}

=head2 set_background

  Set the background color of the image. It must be the first method under the create

=cut

sub set_background {
  my $self                 = shift;
  my $r                    = shift;
  my $g                    = shift;
  my $b                    = shift;
  $self->{IMAGE}->colorAllocate($r,$g,$b); # Set the background color
  $self->{BLACK} = $self->{IMAGE}->colorAllocate(0,0,0);   # Set the black color
  $self->{BLUE}  = $self->{IMAGE}->colorAllocate(100,100,255); # Set the blue color
  $self->{GREEN} = $self->{IMAGE}->colorAllocate(0,100,0); # Set the green color
}

=head2 add_scale

  Add scale to the picture

=cut

sub add_scale {
  my $self                 = shift;

  my $color = $self->{BLACK};

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

  Add scale lines through the whole image background

=cut

sub add_bck_lines {
  my $self                 = shift;
  my $color = $self->{IMAGE}->colorAllocate(220,220,220);

  my $i;
  for ($i = 20; $i < $self->{WIDTH}-10; $i += 10){
          $self->{IMAGE}->line($i,0,$i,$self->{HEIGHT},$color);
      }

}

=head2 add_seq

  Add a specified seq to the picture. This is an internal code, so do not use it directly

=cut

sub add_seq {
  my $self                 = shift;
  my $index                = shift;

  my $seq = $self->{SEQS}->[$index];
  my $len = $seq->get_length;
  my $x1  = $self->{WIDTH} - 10;
  my $x2  = $x1-$len;

  # Draw the seq line
  $self->{IMAGE}->line($x2, $index*70+40, $x1, $index*70+40, $self->{BLACK});

  # Print the seq name and the length
  my $text = $seq->get_taxon_name . " " . $len . " bp";
  $self->{IMAGE}->string(gdTinyFont, $x2, $index*70+30, $text, $self->{BLACK});

  # Draw UTR
  my $utrlen = $seq->get_utr_length;
  if ($utrlen){
      $self->{IMAGE}->filledRectangle($x1-$utrlen, $index*70+35, $x1, $index*70+45, $self->{BLUE});
      $self->{IMAGE}->string(gdTinyFont, $x1-$utrlen, $index*70+36, "UTR ".$utrlen." bp", $self->{BLACK});
  }

  # Draw Motifs
  my @features = @{$seq->get_all_seq_features};
  my $motif_Y = $index*70 + 50;
  for my $feat (@features){
      if ($feat->get_type eq "con"){

          my %motif_element = ($feat->get_motifid => [ $x1-$feat->get_end,
                                                       $motif_Y,
                                                       $x1-$feat->get_start,
                                                       $motif_Y + 5 ]);

          $self->{IMAGE}->filledRectangle($x1-$feat->get_end,
                                          $motif_Y,
                                          $x1-$feat->get_start,
                                          $motif_Y + 5,
                                          $self->{GREEN});
          $self->{IMAGE}->string(gdTinyFont, $x1-$feat->get_end, $motif_Y+10, "m", $self->{BLACK});

          if (($feat->get_start - $feat->get_end) < 10) {
#             $motif_Y += 5;
          }
          else {
             $motif_Y = $index * 70 + 50;
          }

          push @{$self->{MAP}->{"motif"}},\%motif_element;
      }
  }
}

sub add_all_seq {
  my $self                 = shift;
  my @seqs = @{$self->{SEQS}};
  my $i;
  for($i = 0; $i < $#seqs+1; $i++){
     $self->add_seq($i);
  }
}

=head2 get_png

  Return the png image. Use this when you finish the work and would like to see the results.

=cut

sub get_png {
  my $self                 = shift;
  return($self->{IMAGE}->png);
}


=head2 get_image

  Return the drawed image pointer. Useful for add your own GD methods for uniq picture manipulating.

=cut

sub get_image {
  my $self                 = shift;
  return($self->{IMAGE});
}

=head2 get_map

  Return a hash of arrays of hash of arrays reference that is contain the map information.

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

  Return only the arrayref of motif hashes

=cut

sub get_motif_map {
  my $self                 = shift;
  return($self->{MAP}->{motif});
}

=head2 get_motif_id_by_coord

  Maybe this is the most useful method. You can get a motif id, if you specify a coordinate of a point

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

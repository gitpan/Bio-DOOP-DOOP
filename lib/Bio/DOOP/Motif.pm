package Bio::DOOP::Motif;

use strict;
use warnings;

=head1 NAME

  Bio::DOOP::Motif - DOOP database conserved motif object

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

  use Bio::DOOP::Motif;

  $db = Bio::DOOP::DBSQL->connect("user","pass","database","somewhere.where.org");
  my $motif = Bio::DOOP::Motif->new($db,"160945");
  print $motif->seq,":",$motif->start," ",$motif->end,"\n";

=head1 DESCRIPTION

  This object represents the conserved motifs.
  You should not use the constructor directly, but
  sometimes it is useful. In most of the cases you
  get this object from other objects.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=cut

=head2 new

  $motif = Bio::DOOP::Motif->new($db,"1234");
 
  You can create the object with the new method.
  The arguments are the following : Bio::DOOP::DBSQL object, motif_primary_id

=cut

sub new {
	my $dummy          = shift;
	my $db             = shift;
	my $id             = shift;
	my $self           = {};

	my $ret = $db->query("SELECT * FROM motif_feature where motif_feature_primary_id=\"$id\";");

	my @motif = @{$$ret[0]};
	$self->{PRIMARY}   = $motif[0];
	$self->{SUBSET}    = $motif[1];
	$self->{CONSENSUS} = $motif[2];
	$self->{TYPE}      = $motif[3];
	$self->{START}     = $motif[4];
	$self->{END}       = $motif[5];
	$self->{BLOCK}     = $motif[6];
	$self->{MATRIX}    = $motif[7];
	$self->{LOGO}      = $motif[8];
	$self->{SUBSET_ID} = $motif[9];
	bless $self;
	return($self);
}

=head2 type

  Returns the type of the motif.
  (explain a little more)

=cut

sub type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 seq

  Returns the consensus sequence of the motif.

=cut

sub seq {
  my $self                 = shift;
  return($self->{CONSENSUS});
}

=head2 start

  Returns the start position of the motif.

=cut

sub start {
  my $self                 = shift;
  return($self->{START});
}

=head2 end

  Returns the end position of the motif.

=cut

sub end {
  my $self                 = shift;
  return($self->{END});
}

=head2 length

  Returns the length of the motif.

=cut

sub length {
  my $self                 = shift;
  return($self->{END} - $self->{START} + 1);
}

=head2 get_id

  Returns the primary ID of the motif. This is the internal ID from the MySQL database.

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_block

  Return the multiple alignment block from which the motif
  was generated.

  Not yet implemented.

=cut

sub get_block {
  my $self                 = shift;
  return($self->{BLOCK});
}

=head2 get_matrix

  Returns the position frequency matrix of the motif.
  
  Not yet implemented.

=cut

sub get_matrix {
  my $self                 = shift;
  return($self->{MATRIX});
}

=head2 get_logo

  Return the sequence logo of the motif.
  
  Not yet implemented.

=cut

sub get_logo {
  my $self                 = shift;
  return($self->{LOGO});
}

=head2 get_subset_id

  Returns the motif subset primary id.

=cut

sub get_subset_id {
  my $self                 = shift;
  return($self->{SUBSET_ID});
}

1;

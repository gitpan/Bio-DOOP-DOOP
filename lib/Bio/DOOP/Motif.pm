package Bio::DOOP::Motif;

use strict;
use warnings;
use Bio::DOOP::DBSQL;

=head1 NAME

  Bio::DOOP::Motif - DOOP database conserved motif object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Bio::DOOP::Motif;

  $db = Bio::DOOP::DBSQL->connect("user","pass","somewhere.where.org");
  my $motif = Bio::DOOP::Motif->new($db,"160945"); # This is the motif primary id
  print $motif->seq,":",$motif->start," ",$motif->end,"\n";

=head1 DESCRIPTION

  This package represent the conserved motifs.
  You shoud not use directly the constructor but
  some times it is useful. Most of the cases you
  get this object from other objects.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=cut

=head2 new

  Create the new objects from the primary id.
  It has two arguments: the connected database identifier and the primary id

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

  Return the type of the motif

=cut

sub type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 seq

  Return the consensus sequence of the motif (string)

=cut

sub seq {
  my $self                 = shift;
  return($self->{CONSENSUS});
}

=head2 start

  Return the start position of the motif

=cut

sub start {
  my $self                 = shift;
  return($self->{START});
}

=head2 end

  Return the end position of the motif

=cut

sub end {
  my $self                 = shift;
  return($self->{END});
}

=head2 length

  Return the length of the motif

=cut

sub length {
  my $self                 = shift;
  return($self->{END} - $self->{START});
}

=head2 get_id

  Return the motif MySQL primary id

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_block

  Return the motif block. Not yet implemented

=cut

sub get_block {
  my $self                 = shift;
  return($self->{BLOCK});
}

=head2 get_matrix

  Return the motif matrix. Not yet implemented

=cut

sub get_matrix {
  my $self                 = shift;
  return($self->{MATRIX});
}

=head2 get_logo

  Return the motif logo. Not yet implemented

=cut

sub get_logo {
  my $self                 = shift;
  return($self->{LOGO});
}

=head2 get_subset_id

  Return the motif subset primary id. It is used by internal processes

=cut

sub get_subset_id {
  my $self                 = shift;
  return($self->{SUBSETID});
}




1;

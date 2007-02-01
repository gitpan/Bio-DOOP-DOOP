package Bio::DOOP::SequenceFeature;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::SequenceFeature - Object for the sequence features

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

=head1 DESCRIPTION

  This object gives access to the sequence features ( conserved motif, repeat, CpG island,
  TFBS and TSS annotation ).

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

  $seqfeat = Bio::DOOP::SequenceFeature->new($db,"112");
 
  You can create the object with the new method.
  The arguments are the following : Bio::DOOP::DBSQL object, sequence_feature_primary_id

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $id                   = shift;

  my $ret = $db->query("SELECT * FROM sequence_feature WHERE sequence_feature_primary_id = $id;");
  my @fields = @{$$ret[0]};

  $self->{PRIMARY}         = $fields[0];
  $self->{SCORE}           = $fields[1];
  $self->{START}           = $fields[2];
  $self->{END}             = $fields[3];
  $self->{TOPLEFT}         = $fields[4];
  $self->{TOPRIGHT}        = $fields[5];
  $self->{BOTTOMLEFT}      = $fields[6];
  $self->{BOTTOMRIGHT}     = $fields[7];
  $self->{SEQ}             = $fields[8];
  $self->{TYPE}            = $fields[9];
  $self->{MOTIFID}         = $fields[10];
  $self->{TFBSID}          = $fields[11];
  $self->{CPGID}           = $fields[12];
  $self->{REPEATID}        = $fields[13];
  $self->{SSRID}           = $fields[14];
  $self->{TSSID}           = $fields[15];
  $self->{SUBSET_ID}       = $fields[16];
  $self->{SEQ_ID}          = $fields[17];

  if    ($self->{TYPE} eq "ssr"){
	  $ret = $db->query("SELECT * FROM ssr_annotation WHERE ssr_primary_id =".$self->{SSRID});
	  @fields = @{$$ret[0]};
	  $self->{SSRUNIT} = $fields[1];
  }
  elsif ($self->{TYPE} eq "rep"){
	  $ret = $db->query("SELECT * FROM repeat_annotation WHERE repeat_primary_id =".$self->{REPEATID});
	  @fields = @{$$ret[0]};
	  $self->{R_NAME}  = $fields[1];
	  $self->{R_CLASS} = $fields[2];
	  $self->{R_DESC}  = $fields[3];
	  $self->{R_XREF}  = $fields[4];
  }
  elsif ($self->{TYPE} eq "tfbs"){
	  $ret = $db->query("SELECT * FROM tfbs_annotation WHERE tfbs_primary_id =".$self->{TFBSID});
	  @fields = @{$$ret[0]};
	  $self->{TF_NAME} = $fields[1];
	  $self->{TF_ORIG} = $fields[2];
	  $self->{TF_DESC} = $fields[3];
	  $self->{TF_TYPE} = $fields[4];
	  $self->{TF_CONS} = $fields[5];
	  $self->{TF_MTRX} = $fields[6];
	  $self->{TF_XREF} = $fields[7];
  }
  elsif ($self->{TYPE} eq "cpg"){
	  $ret = $db->query("SELECT * FROM cpg_annotation WHERE cpg_primary_id =".$self->{CPGID});
	  @fields = @{$$ret[0]};
	  $self->{CPG_P}  = $fields[1];
  }
  elsif ($self->{TYPE} eq "tss"){
	  $ret = $db->query("SELECT * FROM tss_annotation WHERE tss_primary_id =".$self->{TSSID});
	  @fields = @{$$ret[0]};
	  $self->{T_TYPE}  = $fields[1];
	  $self->{T_ID}    = $fields[2];
	  $self->{T_DESC}  = $fields[3];
	  $self->{T_XREF}  = $fields[4];
  }
  elsif ($self->{TYPE} eq "con"){
	  my $motif = Bio::DOOP::Motif->new($db,$self->{MOTIFID});
	  $self->{MOTIF}   = $motif;
  }

  bless $self;
  return($self);
}

=head2 get_id

  Returns the primary ID of the feature. This is the internal ID from the MySQL database.

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_score

  Returns the score of the feature. We don't really need this now.

=cut

sub get_score {
  my $self                 = shift;
  return($self->{SCORE});
}

=head2 get_start

  Returns the start position of the feature.

=cut

sub get_start {
  my $self                 = shift;
  return($self->{START});
}

=head2 get_end

  Returns the end position of the feature.

=cut

sub get_end {
  my $self                 = shift;
  return($self->{END});
}

=head2 length

  Returns the length of the feature.
  Return type: string

=cut

sub length {
  my $self                 = shift;
  return($self->{END} - $self->{START} + 1);
}

=head2 get_png_topleft

  Nothing to see here. Move along.

=cut

sub get_png_topleft {
  my $self                 = shift;
  return($self->{TOPLEFT});
}

=head2 get_png_topright

  Nothing to see here. Move along.

=cut

sub get_png_topright {
  my $self                 = shift;
  return($self->{TOPRIGHT});
}

=head2 get_png_bottomleft

  Nothing to see here. Move along.

=cut

sub get_png_bottomleft {
  my $self                 = shift;
  return($self->{BOTTOMLEFT});
}

=head2 get_png_bottomright

  Nothing to see here. Move along.

=cut

sub get_png_bottomright {
  my $self                 = shift;
  return($self->{BOTTOMRIGHT});
}

=head2 get_seq

  Returns the sequence of the feature.

=cut

sub get_seq {
  my $self                 = shift;
  return($self->{SEQ});
}

=head2 get_type

  Returns the type of the feature. (con, ssr, tfbs, rep, cpg, tss).

  con  : evolutionary conserved non-coding region
  ssr  : simple sequence repeat
  tfbs : transcription factor binding site
  rep  : repeat
  cpg  : cpg island
  tss  : transcription start site

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_motifid

  Returns the motif primary ID, if the feature type is "con".

=cut

sub get_motifid {
  my $self                 = shift;
  return($self->{MOTIFID});
}

=head2 get_tfbsid

  Returns the tfbs primary ID, if the feature type is "tfbs".

=cut

sub get_tfbsid {
  my $self                 = shift;
  return($self->{TFBSID});
}

=head2 get_cpgid

  Returns the cpg primary ID, if the feature type is "cpg".

=cut

sub get_cpgid {
  my $self                 = shift;
  return($self->{CPGID});
}

=head2 get_repeatid

  Returns the repeat primary ID, if the feature type is "rep".

=cut

sub get_repeatid {
  my $self                 = shift;
  return($self->{REPEATID});
}

=head2 get_ssrid

  Returns the ssr primary ID, if the feature type is "ssr".

=cut

sub get_ssrid {
  my $self                 = shift;
  return($self->{SSRID});
}

=head2 get_tssid

  Returns the tss primary ID, if the feature type is "tss".

=cut

sub get_tssid {
  my $self                 = shift;
  return($self->{TSSID});
}

=head2 get_seqid

  Returns the primary ID of the sequence containing this feature.

=cut

sub get_seqid {
  my $self                 = shift;
  return($self->{SEQ_ID});
}

=head2 get_subsetid

  Returns the subset primary ID of the feature, if the feature type is "con".

=cut

sub get_subsetid {
  my $self                 = shift;
  return($self->{SUBSET_ID});
}

=head2 get_motif

  $motif = $seqfeat->get_motif;
  Returns the motif object associated with the feature.
  If the feature type is not "con" this value is NULL.

=cut

sub get_motif {
  my $self                 = shift;
  return($self->{MOTIF});
}

=head2 get_tss_type

  Returns the tss type, if the feature type is "tss".

=cut

sub get_tss_type {
  my $self                 = shift;
  return($self->{T_TYPE});
}

=head2 get_tss_id

  Returns the tss id, if the feature type is "tss".

=cut

sub get_tss_id {
  my $self                 = shift;
  return($self->{T_ID});
}

=head2 get_tss_desc

  Returns the description of the tss, if the feature type is "tss".

=cut

sub get_tss_desc {
  my $self                 = shift;
  return($self->{T_DESC});
}

=head2 get_tss_xref

  Returns the xref of the tss, if the feature type is "tss".

=cut

sub get_tss_xref {
  my $self                 = shift;
  return($self->{T_XREF});
}

1;

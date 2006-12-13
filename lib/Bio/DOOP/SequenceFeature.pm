package Bio::DOOP::SequenceFeature;

use strict;
use warnings;
use Bio::DOOP::DBSQL;
use Bio::DOOP::Motif;

=head1 NAME

  Bio::DOOP::SequenceFeature - Object for the sequence features

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 DESCRIPTION

  This object give access for the sequence features ( motif, repeat, cpg
  and tss annotaion ). This object also contain some web based code
  for visualize the feature in picture.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=head2 new

  $seqfeat = Bio::DOOP::SequenceFeature->new($db,"112");
  You can create the object with new. The arguments is the following:
  $db is a Bio::DOOP::DBSQL object, the second argument is a
  SequenceFeature primary id.

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

  Return the primary id of the features. Use for MySQL queryes

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_score

  Return the score of the feature. I do not know too much about it.

=cut

sub get_score {
  my $self                 = shift;
  return($self->{SCORE});
}

=head2 get_start

  Return the start position of the feature.

=cut

sub get_start {
  my $self                 = shift;
  return($self->{START});
}

=head2 get_end

  Return the end position of the feature

=cut

sub get_end {
  my $self                 = shift;
  return($self->{END});
}

=head2 get_png_topleft

  Return the picture position of the feature. Used by a web code

=cut

sub get_png_topleft {
  my $self                 = shift;
  return($self->{TOPLEFT});
}

=head2 get_png_topright

  Return the picture position of the feature. Used by a web code

=cut

sub get_png_topright {
  my $self                 = shift;
  return($self->{TOPRIGHT});
}

=head2 get_png_bottomleft

  Return the picture position of the feature. Used by a web code

=cut

sub get_png_bottomleft {
  my $self                 = shift;
  return($self->{BOTTOMLEFT});
}

=head2 get_png_bottomright

  Return the picture position of the feature. Used by a web code

=cut

sub get_png_bottomright {
  my $self                 = shift;
  return($self->{BOTTOMRIGHT});
}

=head2 get_seq

  Return the sequence of the feature.

=cut

sub get_seq {
  my $self                 = shift;
  return($self->{SEQ});
}

=head2 get_type

  Return the type of the feature. (con, ssr, tfbs, rep, cpg, tss)

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_motifid

  Return the motif primary id, if the feature type is con. Else it is NULL

=cut

sub get_motifid {
  my $self                 = shift;
  return($self->{MOTIFID});
}

=head2 get_tfbsid

  Return the tfbs primary id, if the feature type is tfbs. Else it is NULL

=cut

sub get_tfbsid {
  my $self                 = shift;
  return($self->{TFBSID});
}

=head2 get_cpgid

  Return the cpg primary id, if the feature type is cpg. Else it is NULL

=cut

sub get_cpgid {
  my $self                 = shift;
  return($self->{CPGID});
}

=head2 get_repeatid

  Return the repeat primary id, if the feature type is rep. Else it is NULL

=cut

sub get_repeatid {
  my $self                 = shift;
  return($self->{REPEATID});
}

=head2 get_ssrid

  Return the ssr primary id, if the feature type is ssr. Else it is NULL

=cut

sub get_ssrid {
  my $self                 = shift;
  return($self->{SSRID});
}

=head2 get_tssid

  Return the tss primary id, if the feature type is tss. Else it is NULL

=cut

sub get_tssid {
  my $self                 = shift;
  return($self->{TSSID});
}

=head2 get_seqid

  Return the sequence primary id that is contain this feature

=cut

sub get_seqid {
  my $self                 = shift;
  return($self->{SEQ_ID});
}

=head2 get_subsetid

  The get_subsetid method returns the subset primary id of the feature

=cut

sub get_subsetid {
  my $self                 = shift;
  return($self->{SUBSET_ID});
}

=head2 get_motif

  $motif = $seqfeat->get_motif;
  Return the motif object associated to the feature.
  If the feature type is not con this value is NULL

=cut

sub get_motif {
  my $self                 = shift;
  return($self->{MOTIF});
}

=head2 get_tss_type

  Return the tss type, if the feature is tss.

=cut

sub get_tss_type {
  my $self                 = shift;
  return($self->{T_TYPE});
}

=head2 get_tss_id

  Return the tss id, if the feature is tss.

=cut

sub get_tss_id {
  my $self                 = shift;
  return($self->{T_ID});
}

=head2 get_tss_desc

  Return the description of the tss, if the feature is tss

=cut

sub get_tss_desc {
  my $self                 = shift;
  return($self->{T_DESC});
}

=head2 get_tss_xref

  Return the xref of the tss, if the feature is tss

=cut

sub get_tss_xref {
  my $self                 = shift;
  return($self->{T_XREF});
}



1;

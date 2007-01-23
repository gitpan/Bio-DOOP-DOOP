package Bio::DOOP::Cluster;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Cluster - Doop cluster object

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

  This object represent a cluster. You can access properties through the methods.
  Usage:

  $cluster = Bio::DOOP::Cluster->new($db,"81007400","500");
  print $cluster->get_cluster_id;

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
     $self->{ID}           = shift;  # This is the cluster_db_id field in the MySQL
     $self->{PROMO_TYPE}   = shift;

  my $id   = $self->{ID};
  my $size = $self->{PROMO_TYPE};

  my $ret  = $db->query("SELECT * FROM cluster WHERE cluster_db_id=\"$id\" AND cluster_promoter_type=\"$size\";");
  my @cluster = @{$$ret[0]};

  $self->{PRIMARY}         = $cluster[0];  # This is need for the cluster subset query
  $self->{TYPE}            = $cluster[3];
  $self->{DATE}            = $cluster[4];
  $self->{VERSION}         = $cluster[5];
  $self->{DB}              = $db;
  bless $self;
  return ($self);
}

sub new_by_id {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
     $self->{PRIMARY}      = shift;  # This is the cluster_db_id field in the MySQL

  my $id   = $self->{PRIMARY};

  my $ret  = $db->query("SELECT * FROM cluster WHERE cluster_primary_id=\"$id\";");
  my @cluster = @{$$ret[0]};

  $self->{PRIMARY}         = $cluster[0];  # This is need for the cluster subset query
  $self->{PROMO_TYPE}      = $cluster[1];
  $self->{ID}              = $cluster[2];
  $self->{TYPE}            = $cluster[3];
  $self->{DATE}            = $cluster[4];
  $self->{VERSION}         = $cluster[5];
  $self->{DB}              = $db;
  bless $self;
  return ($self);
}

=head1 METHODS

=head2 new

  $cluster = Bio::DOOP::Cluster->new($db,"8010110","500");
  Create a new cluster object from cluster id and promoter type. Every promoter sequence has an uniq number. 
  This number is the cluster id. We have three promoter size (500,1000,3000 bps), so the uniq sequence is
  identified by two parameter: cluster id and promoter type.
  Return type: Bio::DOOP::Cluster

=cut

=head2 new_by_id

  Bio::DOOP::Cluster->new_by_id($db,"2453");
  Used by internal MySQL querys
  Return type: Bio::DOOP::Cluster

=cut

=head2 get_id

  $cluster_id = $cluster->get_id;

  Returns with the MySQL id.
  Return type: string

=cut

sub get_id {
  my $self                 = shift;
  return $self->{PRIMARY};
}

=head2 get_cluster_id

  Returns the cluster id.
  Return type: string

=cut

sub get_cluster_id {
  my $self                 = shift;
  return $self->{ID};
}

=head2 get_promo_type

  $pt = $cluster->get_promo_type;

  Returns the size of the promoter (500,1000,3000 bps). This is the maximum number.
  Return type: string

=cut

sub get_promo_type {
  my $self                 = shift;
  return($self->{PROMO_TYPE});
}

=head2 get_type

  print $cluster->get_type;

  Returns the type of the promoter (The available return types are the following: 1,2,3,4,5,6). 
  See the doop homepage for more details.
  Return type: string

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_date

  $date = $cluster->get_date;

  Returns the cluster time when we add to the database.
  Return type: string

=cut

sub get_date {
  my $self                 = shift;
  return($self->{DATE});
}

=head2 get_version

  print $cluster->get_version;

  Returns the version number.

=cut

sub get_version {
  my $self                 = shift;
  return($self->{VERSION});
}

=head2 get_all_subsets

  @subsets = @{$cluster->get_all_subsets};

  Returns all the subsets that is linked to this cluster.
  Return type: Bio::DOOP::ClusterSubset

=cut

sub get_all_subsets {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_primary_id FROM cluster_subset WHERE cluster_primary_id = $id");

  if ($#$ret == -1){
     cluck "No subset!\n";
     return();
  }

  my @subsets;
  for my $i (@$ret){
	  push @subsets,Bio::DOOP::ClusterSubset->new($self->{DB},$$i[0]);
  }

  return(\@subsets);
}

=head2 get_all_seqs

  @seqs = @{$cluster->get_all_seqs};

  Return all the sequences that are linked to the cluster
  Return type: Bio::DOOP::Sequence

=cut

sub get_all_seqs {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT DISTINCT(sequence_primary_id) FROM subset_xref WHERE cluster_primary_id = $id;");

  if ($#$ret == -1){
     cluck "No seq!\n";
     return();
  }

  my @seqs;
  for my $i (@$ret){
	  push @seqs,Bio::DOOP::Sequence->new($self->{DB},$$i[0]);
  }

  return(\@seqs);
}

=head2 get_orig_subset

  @subsets = @{$cluster->get_orig_subset};

  Return the original subset, that is contain the whole cluster.
  Return type: Bio::DOOP::ClusterSubset

=cut

sub get_orig_subset {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_primary_id FROM cluster_subset WHERE cluster_primary_id = $id AND original = \"y\"");
  if ($#$ret == -1){
     cluck "No original subset!\n";
     return();
  }
  my $subset =  Bio::DOOP::ClusterSubset->new($self->{DB},$$ret[0]->[0]);
  return($subset);
}

=head2 get_ref_seq

  $refseq = $cluster->get_ref_seq;

  Return the cluster reference sequence (human or arabidopsis).
  Return type: Bio::DOOP::Sequence

=cut

sub get_ref_seq {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};

  my $ret = $self->{DB}->query("SELECT sequence.sequence_primary_id FROM sequence, taxon_annotation, subset_xref WHERE cluster_primary_id = $id AND (taxon_name = 'Arabidopsis thaliana' OR taxon_name = 'Homo sapiens') AND taxon_annotation.taxon_primary_id = sequence.taxon_primary_id AND sequence.sequence_primary_id = subset_xref.sequence_primary_id;");
  
  my $seq = Bio::DOOP::Sequence->new($self->{DB},$$ret[0]->[0]);
  return($seq);
}


1;

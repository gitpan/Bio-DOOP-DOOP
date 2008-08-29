package Bio::DOOP::Cluster;

use strict;
use warnings;

=head1 NAME

  Bio::DOOP::Cluster - DoOP cluster object

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

=head1 SYNOPSIS

  This object represents a cluster. You can access the properties through the methods.

  Usage:

  $cluster = Bio::DOOP::Cluster->new($db,"81007400","500");
  print $cluster->get_cluster_id;

=head1 DESCRIPTION

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
     $self->{ID}           = shift;  # cluster_id field in the MySQL tables.
     $self->{PROMO_TYPE}   = shift;

  my $id   = $self->{ID};
  my $size = $self->{PROMO_TYPE};

  my $ret  = $db->query("SELECT * FROM cluster WHERE cluster_id=\"$id\" AND cluster_promoter_type=\"$size\";");

  if ($#$ret == -1){
     return(-1);
  }

  my @cluster = @{$$ret[0]};

  $self->{PRIMARY}         = $cluster[0];
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
     $self->{PRIMARY}      = shift;  # cluster_id field in the MySQL tables.

  my $id   = $self->{PRIMARY};

  my $ret  = $db->query("SELECT * FROM cluster WHERE cluster_primary_id=\"$id\";");

  if ($#$ret == -1){
     return(-1);
  }

  my @cluster = @{$$ret[0]};

  $self->{PRIMARY}         = $cluster[0];
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

  Create a new cluster object from the cluster id and promoter type. Every promoter cluster has a unique
  identifier. This is the cluster id. There are three promoter sizes (500,1000,3000 bp), so the unique
  cluster is identified by two parameters : cluster id and promoter type.

  Return type :

  Bio::DOOP::Cluster object

=cut

=head2 new_by_id

  Bio::DOOP::Cluster->new_by_id($db,"2453");

  Used by internal MySQL queries.
  Return type :

  Bio::DOOP::Cluster object

=cut

=head2 get_id

  $cluster_id = $cluster->get_id;

  Returns the MySQL id.

  Return type :

  string

=cut

sub get_id {
  my $self                 = shift;
  return $self->{PRIMARY};
}

=head2 get_cluster_id

  $cluster_id = $cluster->get_cluster_id;

  Returns the cluster id.
  Return type: string

=cut

sub get_cluster_id {
  my $self                 = shift;
  return $self->{ID};
}

=head2 get_promo_type

  $pt = $cluster->get_promo_type;

  Returns the size of the promoter (500,1000,3000 bp).
  Return type: string

=cut

sub get_promo_type {
  my $self                 = shift;
  return($self->{PROMO_TYPE});
}

=head2 get_type

  print $cluster->get_type;

  Returns the type of the promoter (The available return types are the following: 1,2,3,4,5n,6n). 
  See http://doop.abc.hu for more details.
  Return type: string

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_date

  $date = $cluster->get_date;

  Returns the date when the cluster was last modified.
  Return type: string

=cut

sub get_date {
  my $self                 = shift;
  return($self->{DATE});
}

=head2 get_version

  print $cluster->get_version;

  Returns the version of the cluster.
  Return type: string

=cut

sub get_version {
  my $self                 = shift;
  return($self->{VERSION});
}

=head2 get_all_subsets

  @subsets = @{$cluster->get_all_subsets};

  Returns the arrayref of all subsets associated with the cluster.
  Return type: arrayref, the array containing Bio::DOOP::ClusterSubset objects

=cut

sub get_all_subsets {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_primary_id FROM cluster_subset WHERE cluster_primary_id = $id");

  if ($#$ret == -1){
     return(-1);
  }

  my @subsets;
  for my $i (@$ret){
	  push @subsets,Bio::DOOP::ClusterSubset->new($self->{DB},$$i[0]);
  }

  return(\@subsets);
}

=head2 get_subset_by_type

  $subset = $cluster->get_subset_by_type("B");
  if ($subset == -1){
     print"No subset! Try another subset type\n";
  }

  Returns the subset specified by type.
  Return type: Bio::DOOP::ClusterSubset object

=cut

sub get_subset_by_type {
  my $self                 = shift;
  my $type                 = shift;

  my $id  = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_primary_id FROM cluster_subset WHERE cluster_primary_id = $id AND subset_type = \"$type\"");

  if ($#$ret == -1){
     return(-1);
  }

  my $subset = Bio::DOOP::ClusterSubset->new($self->{DB},$$ret[0]->[0]);
  return($subset);
}

=head2 get_available_types

  @types = @{$cluster->get_available_types};

  Returns all available cluster subset types.
  Return type: arrayref of string

=cut

sub get_available_types {
  my $self                 = shift;
  my $id = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_type FROM cluster_subset WHERE cluster_primary_id = $id");

  if ($#$ret == -1){
     return(-1);
  }

  my @types;

  for my $i (@$ret){
     push @types,$$i[0];
  }
  return(\@types);
}

=head2 get_all_seqs

  @seqs = @{$cluster->get_all_seqs};

  Returns the arrayref of all sequences associated with the cluster.
  Return type: arrayref, the array containig Bio::DOOP::Sequence objects

=cut

sub get_all_seqs {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT DISTINCT(sequence_primary_id) FROM subset_xref WHERE cluster_primary_id = $id;");

  if ($#$ret == -1){
     return(-1);
  }

  my @seqs;
  for my $i (@$ret){
     push @seqs,Bio::DOOP::Sequence->new($self->{DB},$$i[0]);
  }

  return(\@seqs);
}

=head2 get_orig_subset

  @subsets = @{$cluster->get_orig_subset};

  Returns the original subset, containing the whole cluster.
  Return type: Bio::DOOP::ClusterSubset object

=cut

sub get_orig_subset {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};
  my $ret = $self->{DB}->query("SELECT subset_primary_id FROM cluster_subset WHERE cluster_primary_id = $id AND original = \"y\"");
  if ($#$ret == -1){
     return(-1);
  }
  my $subset =  Bio::DOOP::ClusterSubset->new($self->{DB},$$ret[0]->[0]);
  return($subset);
}

=head2 get_ref_seq

  $refseq = $cluster->get_ref_seq;

  Returns the cluster reference sequence (human or arabidopsis).
  Return type: Bio::DOOP::Sequence object

=cut

sub get_ref_seq {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};

  my $ret = $self->{DB}->query("SELECT sequence.sequence_primary_id FROM sequence, taxon_annotation, subset_xref WHERE cluster_primary_id = $id AND (taxon_taxid = '3702' OR taxon_taxid = '9606') AND taxon_annotation.taxon_primary_id = sequence.taxon_primary_id AND sequence.sequence_primary_id = subset_xref.sequence_primary_id;");
  
  if ($#$ret == -1){
     return(-1);
  }

  my $seq = Bio::DOOP::Sequence->new($self->{DB},$$ret[0]->[0]);
  return($seq);
}

1;

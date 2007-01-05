package Bio::DOOP::Cluster;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Cluster - Doop cluster object

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

  This object represent the cluster.
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
  Create a new cluster object from cluster id and promoter type

=cut

=head2 new_by_id

  Bio::DOOP::Cluster->new_by_id($db,"2453");
  Used by internal MySQL querys

=cut

=head2 get_id

  $cluster_id = $cluster->get_id;

  Return with the MySQL id.

=cut

sub get_id {
  my $self                 = shift;
  return $self->{PRIMARY};
}

=head2 get_cluster_id

  Return the cluster id

=cut

sub get_cluster_id {
  my $self                 = shift;
  return $self->{ID};
}

=head2 get_promo_type

  $pt = $cluster->get_promo_type;

  Visszaadja a promoter elvi meretet (500,1000,3000 bp elvi meretu lehet)

=cut

sub get_promo_type {
  my $self                 = shift;
  return($self->{PROMO_TYPE});
}

=head2 get_type

  print $cluster->get_type;

  Visszaadja a promoter tipusat (1,2,3,4,5,6 tipusu lehet az exonok fugvenyeben)

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_date

  $date = $cluster->get_date;

  Az adatbazisba kerulesenek az idopontja

=cut

sub get_date {
  my $self                 = shift;
  return($self->{DATE});
}

=head2 get_version

  print $cluster->get_version;

  A cluster verzioszama

=cut

sub get_version {
  my $self                 = shift;
  return($self->{VERSION});
}

=head2 get_all_subsets

  This is return with all the subsets linked to the cluster
  @subsets = @{$cluster->get_all_subsets};

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

  Return the original subset, that is contain the whole cluster

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

  Return the cluster reference sequence (human or arabidopsis)

=cut

sub get_ref_seq {
  my $self                 = shift;
  my $id                   = $self->{PRIMARY};

  my $ret = $self->{DB}->query("SELECT sequence.sequence_primary_id FROM sequence, taxon_annotation, subset_xref WHERE cluster_primary_id = $id AND (taxon_name = 'Arabidopsis thaliana' OR taxon_name = 'Homo sapiens') AND taxon_annotation.taxon_primary_id = sequence.taxon_primary_id AND sequence.sequence_primary_id = subset_xref.sequence_primary_id;");
  
  my $seq = Bio::DOOP::Sequence->new($self->{DB},$$ret[0]->[0]);
  return($seq);
}


1;

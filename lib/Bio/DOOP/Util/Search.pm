package Bio::DOOP::Util::Search;

use strict;
use warnings;
#use Bio::DOOP::DBSQL;
use Bio::DOOP::Motif;
use Bio::DOOP::Cluster;
use Bio::DOOP::ClusterSubset;
use Bio::DOOP::Sequence;

=head1 NAME

  Bio::DOOP::Util::Search - useful subrutines for easy search

=head1 VERSION

  Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

  use Bio::DOOP::DOOP;

  $db = Bio::DOOP::DBSQL->connect("doopuser","dooppasswd","doop-plant","localhost");
  @motifs = @{Bio::DOOP::Util::Search::get_all_motifs_by_type($db,"V")};

=head1 DESCRIPTION

  Collection of utilities managing big queries. Most of
  the subrutines return arrayrefs of motifs, sequences, clusters.
  For example: You want all the motifs that can be found in al of the
  subsets. Instead of you go through all the motif in the jungle of 
  SQL querys, you use the ... subrutine. Your code will be more 
  simple.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 SUBRUTINES

=head2 get_all_motifs_by_type

  Return the arrayref of all motifs that type is specified in the argument.

=cut

sub get_all_motifs_by_type {
  my $db                   = shift;
  my $type                 = shift;

  my @motifs;
  my $ret = $db->query("SELECT motif_feature_primary_id FROM motif_feature WHERE motif_type = \"$type\";");
  for my $motif_id (@$ret){
	  push @motifs,Bio::DOOP::Motif->new($db,$$motif_id[0]);
  }
  return(\@motifs);
}

=head2 get_all_original_subset

  Return the arrayref of all original subset.

=cut

sub get_all_original_subset {
  my $db                   = shift;
  my @subsets;
  my $ret = $db->query("SELECT subset_primary_id FROM cluster_subset WHERE original = \"y\";");
  for my $subset (@$ret){
	  push @subsets,Bio::DOOP::ClusterSubset->new($db,$$subset[0]);
  }
  return(\@subsets);
}

=head2 get_all_cluster_by_gene_id

  Return the arrayref of all clusters defined by the gene id

=cut

sub get_all_cluster_by_gene_id  {
  my $db                   = shift;
  my $gene_id              = shift;
  my $promoter_size        = shift;

  my @clusters;
  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster,sequence,subset_xref,sequence_annot WHERE sequence.sequence_annot_primary_id = sequence_annot.sequence_annot_primary_id AND subset_xref.sequence_primary_id = sequence.sequence_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence_annot.sequence_gene_name LIKE '$gene_id%';");

  for my $cluster (@$ret){
          push @clusters,Bio::DOOP::Cluster->new($db,$$cluster[0],$promoter_size);
  }
  return(\@clusters);
}

=head2 get_all_cluster_by_keyword

  Return all clusters that is contain the keyword in its description, tss annotation or sequence xref

=cut

sub get_all_cluster_by_keyword {
  my $db                   = shift;
  my $keyword              = shift;
  my $promoter_size        = shift;

  my @clusters;
  my @cluster_db_id;
  my %seen;

  # Query from sequence_annot
  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, sequence_annot, sequence, subset_xref WHERE subset_xref.sequence_primary_id = sequence.sequence_primary_id AND sequence.sequence_annot_primary_id = sequence_annot.sequence_annot_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence_annot.sequence_desc LIKE '%$keyword%';");
    for my $cluster (@$ret){
          push @cluster_db_id,$$cluster[0];
  }

  # Query from sequence_xref
  $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, sequence_xref, subset_xref WHERE subset_xref.sequence_primary_id = sequence_xref.sequence_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence_xref.xref_id LIKE '%$keyword%';");
  for my $cluster (@$ret){
          push @cluster_db_id,$$cluster[0];
  }

  # Query from tss_annot
  $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, tss_annotation, sequence_feature, subset_xref WHERE subset_xref.sequence_primary_id = sequence_feature.sequence_primary_id AND sequence_feature.tss_primary_id = tss_annotation.tss_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND tss_annotation.tss_desc LIKE '%$keyword%';");
  for my $cluster (@$ret){
          push @cluster_db_id,$$cluster[0];
  }

  #Remove the redundant cluster_db_ids
  my @cluster_id_uniq = grep { ! $seen{ $_ }++ } @cluster_db_id;

  for my $cluster (@cluster_id_uniq){
          push @clusters,Bio::DOOP::Cluster->new($db,$cluster,$promoter_size);
  }
  
  return(\@clusters);
}

=head2 get_all_cluster_by_type

  Return the arrayref of clusters that xref contain this type and value

=cut

sub get_all_cluster_by_type {
  my $db                   = shift;
  my $type                 = shift;
  my $value                = shift;
  my $promoter_size        = shift;

  my @clusters;

  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, sequence_xref, subset_xref WHERE sequence_xref.sequence_primary_id = subset_xref.sequence_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence_xref.xref_type = '$type' AND sequence_xref.xref_id = '$value';");

  for my $cluster (@$ret){
	  push @clusters,Bio::DOOP::Cluster->new($db,$$cluster[0],$promoter_size);
  }

  return(\@clusters);
}

=head2 get_all_cluster_by_taxon_name

  Return the arrayref of clusters that is contain this taxon name

=cut

sub get_all_cluster_by_taxon_name {
  my $db                   = shift;
  my $taxon                = shift;
  my $promoter_size        = shift;

  my @clusters;

  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, taxon_annotation, sequence, subset_xref WHERE subset_xref.sequence_primary_id = sequence.sequence_primary_id AND sequence.taxon_primary_id = taxon_annotation.taxon_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND taxon_annotation.taxon_name = '$taxon';");

  for my $cluster (@$ret){
	  push @clusters,Bio::DOOP::Cluster->new($db,$$cluster[0],$promoter_size);
  }
  return(\@clusters);
}

=head2 get_all_cluster_by_taxon_id

  Return the arrayref of clusters that is contain this taxon id

=cut

sub get_all_cluster_by_taxon_id {
  my $db                   = shift;
  my $taxon                = shift;
  my $promoter_size        = shift;

  my @clusters;

  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, taxon_annotation, sequence, subset_xref WHERE subset_xref.sequence_primary_id = sequence.sequence_primary_id AND sequence.taxon_primary_id = taxon_annotation.taxon_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND taxon_annotation.taxon_taxid = '$taxon';");

  for my $cluster (@$ret){
	  push @clusters,Bio::DOOP::Cluster->new($db,$$cluster[0],$promoter_size);
  }
  return(\@clusters);
}

=head2 get_all_cluster_by_sequence_id
  
  Returns the arrayref of clusters containing the given sequence id (fake GI)

=cut

sub get_all_cluster_by_sequence_id {
  my $db                   = shift;
  my $sequence_id          = shift;
  my $promoter_size        = shift;

  my @clusters;

  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, sequence, subset_xref WHERE subset_xref.sequence_primary_id = sequence.sequence_primary_id AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence.sequence_fake_gi LIKE '$sequence_id%';");

  for my $cluster (@$ret){
	push @clusters,Bio::DOOP::Cluster->new($db,$$cluster[0],$promoter_size);
  }
  return(\@clusters);
}

=head2 get_all_cluster_by_atno

  Returns the arrayref of clusters containing the given At Number

=cut

sub get_all_cluster_by_atno {
  my $db                   = shift;
  my $atno                 = shift;
  my $promoter_size        = shift;

  my @clusters;

  my $ret = $db->query("SELECT DISTINCT(cluster.cluster_db_id) FROM cluster, sequence_xref, subset_xref WHERE subset_xref.sequence_primary_id = sequence_xref.sequence_primary_id AND sequence_xref.xref_type = 'at_no' AND cluster.cluster_primary_id = subset_xref.cluster_primary_id AND sequence_xref.xref_id LIKE '$atno%';");

  for my $cluster (@$ret) {
	push @clusters,Bio::DOOP::Cluster->new_by_id($db,$$cluster[0]);
  }
  return(\@clusters);
}

=head2 get_all_seq_by_motifid

  Return the arrayref of sequences containing the given motif id

=cut

sub get_all_seq_by_motifid {
  my $db                   = shift;
  my $motifid              = shift;
  my @seqs;

  my $ret = $db->query("SELECT sequence_primary_id FROM sequence_feature WHERE motif_feature_primary_id = $motifid;");

  for my $seq (@$ret){
      push @seqs,Bio::DOOP::Sequence->new($db,$$seq[0]);
  }

  return(\@seqs);
}

1;

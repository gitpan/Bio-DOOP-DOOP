package Bio::DOOP::ClusterSubset;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::ClusterSubset - One element of the cluster

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

  @cluster_subsets = @{$cluster->get_all_subsets};


=head1 DESCRIPTION

  This object is represents one element from the cluster.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=head2 new

  This is the object creation process. Most of the cases you not need to use.
  $db = Bio::DOOP::DBSQL->connect("doopuser","dooppasswd","localhost");
  $cluster_subset = Bio::DOOP::ClusterSubset->new($db,"123");

=cut


sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $id                   = shift;

  my $ret    = $db->query("SELECT * FROM cluster_subset WHERE subset_primary_id = \"$id\";");
  my @fields = @{$$ret[0]};

  $self->{DB}              = $db;
  $self->{PRIMARY}         = $id;
  $self->{TYPE}            = $fields[1];
  $self->{SEQNO}           = $fields[2];
  $self->{MOTIFNO}         = $fields[3];
  $self->{FEATNO}          = $fields[4];
  $self->{ORIG}            = $fields[5];
  $self->{CLUSTER}         = Bio::DOOP::Cluster->new_by_id($db,$fields[6]);

  $ret = $db->query("SELECT alignment_dialign,alignment_fasta FROM cluster_subset_data WHERE subset_primary_id = \"$id\";");

  @fields = @{$$ret[0]};

  $self->{DIALIGN}          = $fields[0];
  $self->{FASTA}            = $fields[1];

  bless $self;
  return($self);
}

=head2 get_id

  print $cluster_subset->get_id;
  Print out the subset primary id. It is the MySQL field id.

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_type

  print $cluster_subset->get_type;
  print out the subset type. 

=cut

sub get_type {
  my $self                 = shift;
  return($self->{TYPE});
}

=head2 get_seqno

  for(i = 0; i < $cluster_subset->get_seqno; i++){
      print $seq[$i];
  }
  print out all of the sequences that linked to the subset.
  get_seqno is the number of the sequences.

=cut

sub get_seqno {
  my $self                 = shift;
  return($self->{SEQNO});
}

=head2 get_featno

  if ($cluster_subset->get_featno > 4){
      print "Lots of features have\n";
  }
  get_featno is the number of the features that linked to the subset

=cut

sub get_featno {
  my $self                 = shift;
  return($self->{FEATNO});
}

=head2 get_motifno

  get_motifno is the number of the motifs that linked to the subset

=cut

sub get_motifno {
  my $self                 = shift;
  return($self->{MOTIFNO});
}

=head2 get_orig

  if ($cluster_subset->get_orig eq "y") {
      print"The subset is original\n";
  }
  elsif ($cluster_subset->get_orig eq "n"){
      print"The subset is not original\n";
  }
  if the subset is original, then print: The subset is original
  otherwise print: The subset is not original

=cut

sub get_orig {
  my $self                 = shift;
  return($self->{ORIG});
}

=head2 get_cluster

  $cluster_id = $cluster_subset->get_cluster;
  the variable is equal with the cluster id, that is contain the subset

=cut

sub get_cluster {
  my $self                 = shift;
  return($self->{CLUSTER});
}

=head2 get_dialign

  print $cluster_subset->get_dialign;
  Print out the dialign alignment of the subset

=cut

sub get_dialign {
  my $self                 = shift;
  return($self->{DIALIGN});
}

=head2 get_fasta_align

  print $cluster_subset->get_fasta_align;
  Print out the fasta alignment of the subset

=cut

sub get_fasta_align {
  my $self                 = shift;
  return($self->{FASTA});
}

=head2 get_all_motifs

  @motifs = @{$cluster_subset->get_all_motifs};
  return the arrayref of all the motifs that contained by the subset

=cut

sub get_all_motifs {
  my $self                 = shift;

  my $id                   = $self->{PRIMARY};
  my $i;
  my @motifs;

  my $ret = $self->{DB}->query("SELECT motif_feature_primary_id FROM motif_feature WHERE subset_primary_id = $id;");

  if ($#$ret == -1){
     cluck "No motif!\n";
     return();
  }

  for($i = 0; $i < $#$ret + 1; $i++){
	  push @motifs,Bio::DOOP::Motif->new($self->{DB},$$ret[$i]->[0]);
  }

  return(\@motifs);
}

=head2 get_all_seqs

  @seq = @{$cluster_subset->get_all_seqs};
  Return the arrayref of all the sequences that contained by the subset

=cut

sub get_all_seqs {
  my $self                 = shift;

  my $id                   = $self->{PRIMARY};
  my @seqs;
  my $ret = $self->{DB}->query("SELECT sequence_primary_id FROM subset_xref WHERE subset_primary_id = $id;");

  if ($#$ret == -1){
     cluck "No sequence!\n";
     return();
  }

  for(@$ret){
	  push @seqs,Bio::DOOP::Sequence->new($self->{DB},$_->[0]);
  }
  return(\@seqs);
}



1;

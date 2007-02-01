package Bio::DOOP::Util::Run::Mofext;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Util::Run::Mofext - Mofext runner module

=head1 VERSION

  Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

#!/usr/bin/perl -w

use Bio::DOOP::DOOP
$db      = Bio::DOOP::DBSQL->connect("user","pass","doop-plant-1_5","localhost");

@list = ("81001020","81001110","81001200","81001225","81001230","81001290","81001470","81001580","81001610","81001620","81001680","81001680","81001690","81001725","81001780","81001930","81001950","81002100","81002130","81002140","81002160");

$mofext = Bio::DOOP::Util::Run::Mofext->new($db,'500',\@list);

$mofext->set_tmp_file_name("/data/DOOP/dummy.txt");

print $mofext->get_tmp_file_name,"\n";

$error = $mofext->write_to_tmp;

if($error != 0){
   die"Write error\n";
}

$error = $mofext->run('TTGGGC' , 6 , 0.6 , '/data/default_matrix' );

if ($error == -1){
   die"No results or error\n";
}

@res = @{$mofext->get_results};
# Return the cluster object and the motif primary id
for $result (@res){
  print $$result[0]->get_id," ",$$result[1],"\n";
}


=head1 DESCRIPTION

  Mofext is a motif search utility developed by Tibor Nagy. This module is a wrapper
  object for this tool. Is is allowed to the user to search similar motifs in the 
  DOOP database.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 SUBRUTINES

=head2 new

  Create a new Mofext running object.
  Arguments: DBSQL object, promoter type (500,1000,3000), listref of cluster id

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $cluster_id_list      = shift;
  my @motif_collection;

  for my $cl_id (@{$cluster_id_list}){
     my $cl = Bio::DOOP::Cluster->new($db,,$cl_id,$promo_type);
     my @subsets = @{$cl->get_all_subsets};
     for my $subset (@subsets){
        my $motifs = $subset->get_all_motifs;
        if(!$motifs){
           cluck("No motifs, so I leap through.\n")
        }
        for my $motif (@$motifs){
           push @motif_collection, [$motif->get_id,$motif->seq];
#           print $motif->get_id," ",$motif->seq,"\n";
        }
     }
  }

  $self->{DB}              = $db;
  $self->{CLLIST}          = $cluster_id_list;
  $self->{TMP_FILE}        = "/tmp/mofext_run.txt";
  $self->{MOTIF_COLL}      = \@motif_collection;

  bless $self;
  return($self);
}

=head2 new_by_file

  Create a new Mofext running object from a file.
  Arguments: DBSQL object, promoter type (500, 1000, 3000), filename of the cluster ids

=cut

sub new_by_file {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $filename             = shift;
  my @motif_collection;
  my @cluster_id_list;

  open CLUSTER_ID_FILE,$filename or cluck("No such file or directory\n");
  while(<CLUSTER_ID_FILE>){
     chomp;
     my $cl_id = $_;
     push @cluster_id_list,$cl_id;
     my $cl = Bio::DOOP::Cluster->new($db,,$cl_id,$promo_type);
     my @subsets = @{$cl->get_all_subsets};
     for my $subset (@subsets){
        my $motifs = $subset->get_all_motifs;
        if(!$motifs){
           cluck("No motifs, so I leap through.\n");
        }
        for my $motif (@$motifs){
           push @motif_collection, [$motif->get_id,$motif->seq];
#           print $motif->get_id," ",$motif->seq,"\n";
        }
     }

  }
  close CLUSTER_ID_FILE;

  $self->{DB}              = $db;
  $self->{CLLIST}          = \@cluster_id_list;
  $self->{TMP_FILE}        = "/tmp/mofext_run.txt";
  $self->{MOTIF_COLL}      = \@motif_collection;

  bless $self;
  return($self);
}

=head2 get_tmp_file_name

  Get the temporary file name.
  Return type: string

=cut

sub get_tmp_file_name {
  my $self                 = shift;
  return($self->{TMP_FILE});
}

=head2 set_tmp_file_name

  Set the temporary file name.
  Return type: none

=cut

sub set_tmp_file_name {
  my $self                 = shift;
  my $file_name            = shift;
  $self->{TMP_FILE} = $file_name;
}

=head2 write_to_tmp

  Write out the collected motifs to the temporary file.
  This step is important for mofext.
  Return type: 0 -> success -1 -> error

=cut

sub write_to_tmp {
  my $self                 = shift;

  open OUT,">".$self->{TMP_FILE} or return(-1);
  for my $motif (@{$self->{MOTIF_COLL}}) {
     print OUT $$motif[0]," ",$$motif[1]," ",length($$motif[1]),"\n";
  }
  close OUT;

  return(0);
}

=head2 run

  Run program mofext in temporary file
  Arguments: query seq, wordsize, cutoff, matrix file name
  Return type: 0 -> success, -1 -> no results or error

=cut

sub run {
  my $self                 = shift;
  my $query                = shift;
  my $wordsize             = shift;
  my $cutoff               = shift;
  my $matrix_file          = shift;

  my %seen;

  my $params = "-q $query -m $matrix_file -w $wordsize -c $cutoff -d ".$self->get_tmp_file_name." -o i";
  my @results = `mofext $params`;

  my @id_uniq = grep { ! $seen{ $_ }++ } @results;
  if ($#id_uniq == -1){return(-1)} # No results

  $self->{RESULT}          = \@id_uniq;  # Listref of hit motif ids.
  return(0);
}

=head2 get_results

  Returns the arrayref of array of cluster objects and motif primary ids

=cut

sub get_results {
  my $self                 = shift;

  my $res = $self->{RESULT};
  my @cluster_res;

  for my $id (@{$res}) {
     chomp($id);
     my $motif     = Bio::DOOP::Motif->new($self->{DB},$id);
     my $subsetid  = $motif->get_subset_id;
     my $subset    = Bio::DOOP::ClusterSubset->new($self->{DB},$subsetid);
     my $cluster   = $subset->get_cluster;

     push @cluster_res, [$cluster,$id];
  }

  return(\@cluster_res);
}






1;

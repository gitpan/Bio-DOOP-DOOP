package Bio::DOOP::Util::Run::Mofext;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Util::Run::Mofext - Mofext runner module.

=head1 VERSION

  Version 0.15

=cut

our $VERSION = '0.15';

=head1 SYNOPSIS

#!/usr/bin/perl -w

use Bio::DOOP::DOOP
$db     = Bio::DOOP::DBSQL->connect("user","pass","doop-plant-1_5","localhost");

@list   = ("81001020","81001110","81001200","81001225","81001230","81001290","81001470","81001580","81001610","81001620","81001680","81001680","81001690","81001725","81001780","81001930","81001950","81002100","81002130","81002140","81002160");

$mofext = Bio::DOOP::Util::Run::Mofext->new($db,'500','M',\@list);

$mofext->set_tmp_file_name("/data/DOOP/dummy.txt");

print $mofext->get_tmp_file_name,"\n";

$error = $mofext->write_to_tmp;

if($error != 0){
   die "Write error!\n";
}

$error = $mofext->run('TTGGGC' , 6 , 0.6 , '/data/default_matrix' );

if ($error == -1){
   die "No results or error!\n";
}

@res = @{$mofext->get_results};
# Return the motif objects and the score, extended score.
for $result (@res){
  print $$result[0]->get_id," ",$$result[1],"$$result[2]","\n";
}


=head1 DESCRIPTION

  Mofext is a fuzzy sequence pattern search tool developed by Tibor Nagy. This module 
  is a wrapper object for mofext. It allows the user to search for similar motifs in the 
  DOOP database.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 SUBRUTINES

=head2 new

  Create a new Mofext object.
  Arguments: DBSQL object, promoter type (500,1000,3000), subset type (B,M,E,V in plants) arrayref of cluster ids.

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $subset_type          = shift;
  my $cluster_id_list      = shift;
  my @motif_collection;

  for my $cl_id (@{$cluster_id_list}){
     my $cl      = Bio::DOOP::Cluster->new($db,$cl_id,$promo_type);
     if ($cl == -1){ next }
     my $subset  = $cl->get_subset_by_type($subset_type);
     if ($subset == -1){ next }
     my $motifs  = $subset->get_all_motifs;
     if($motifs  == -1){ next }
     for my $motif (@$motifs){
        push @motif_collection, [$motif->get_id,$motif->seq];
#       print $motif->get_id," ",$motif->seq,"\n";
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

  Create a new Mofext object from a file.
  Arguments: DBSQL object, promoter type (500, 1000, 3000), subset type (B,M,E,V in plants), name of the file with cluster ids.

=cut

sub new_by_file {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $subset_type          = shift;
  my $filename             = shift;
  my @motif_collection;
  my @cluster_id_list;

  open CLUSTER_ID_FILE,$filename or cluck("No such file or directory!\n");
  while(<CLUSTER_ID_FILE>){
     chomp;
     my $cl_id = $_;
     push @cluster_id_list,$cl_id;
     my $cl = Bio::DOOP::Cluster->new($db,$cl_id,$promo_type);
     my $subset = $cl->get_subset_by_type($subset_type);
     if ($subset == -1) { next }
     my $motifs = $subset->get_all_motifs;
     if($motifs == -1){ next }
     for my $motif (@$motifs){
        push @motif_collection, [$motif->get_id,$motif->seq];
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

=head2 new_by_tmp

  Create a new Mofext object from a existed tmp file. It is good when you have a tmp file, and you want 
  to use it over and over again or your tmp file is large (the new constructor is very slow when you use
  big cluster list). If you use this constructor, you no need to use set_tmp_file_name, write_to_tmp.
  Arguments: Bio::DOOP::DBSQL object, temporary file name.
  Return type: none
  Example:

  use Bio::DOOP::DOOP
  $db      = Bio::DOOP::DBSQL->connect("username","pswd","doop-chordate-1_4","localhost");

  $mofext = Bio::DOOP::Util::Run::Mofext->new_by_tmp($db,"/adatok/prg/perl/DOOP/ize.txt");
  $ret = $mofext->run('GGATCCTGGAT',10,0.95,'default_matrix.txt');
  @res = @{$mofext->get_results};

  for $res (@res){
    print $$res[0]->get_id," ",$$res[1],"\n";
  }


=cut

sub new_by_tmp {
  my $self                 = {};
  my $dummy                = shift;
     $self->{DB}           = shift;
     $self->{TMP_FILE}     = shift;

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
  Arguments: temporary file name
  Return type: none

=cut

sub set_tmp_file_name {
  my $self                 = shift;
  my $file_name            = shift;
  $self->{TMP_FILE} = $file_name;
}

=head2 write_to_tmp

  Write out the collected motifs to the temporary file.
  Return type: 0 -> success, -1 -> error

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

  Run mofext on temporary file, containing motifs.
  Arguments: query sequence, wordsize, cutoff, matrix file path.
  Return type: 0 -> success, -1 -> no result or error

=cut

sub run {
  my $self                 = shift;
  my $query                = shift;
  my $wordsize             = shift;
  my $cutoff               = shift;
  my $matrix_file          = shift;

  my %seen;

  my $params = "-q $query -m $matrix_file -w $wordsize -c $cutoff -d ".$self->get_tmp_file_name." -o iseqDfF";
  my @results = `mofext $params`;

  my @id_uniq = grep { ! $seen{ $_ }++ } @results;

  if ($#id_uniq == -1){return(-1)} # No result.

  $self->{RESULT} = \@id_uniq;  # Arrayref of motif ids.
  return(0);
}

=head2 run_background

  Run mofext, but don not wait for the end
  Arguents: query sequence, wordsize, cutoff, matrix file path, output file name
  Return type: the process id

=cut

sub run_background {
  my $self                 = shift;
  my $query                = shift;
  my $wordsize             = shift;
  my $cutoff               = shift;
  my $matrix_file          = shift;
  my $outfile              = shift;
  my $pid;

  unless($pid = fork){

  my $params = "-q $query -m $matrix_file -w $wordsize -c $cutoff -d ".$self->get_tmp_file_name." -o iseqDfF";
  my @results = `mofext $params | sort | uniq >$outfile`;
  }

  return($pid);
}

=head2 get_results

  Returns the arrayref of array of motif objects and score, extended score, full hit sequence,
  alignment start position in the query sequence, alignment start position in the hit sequence.

=cut

sub get_results {
  my $self                 = shift;

  my $res = $self->{RESULT};
  my @mofext_res;
  my $id;
  my $score;
  my $extscore;
  my $fullhit;
  my $querystart;
  my $hitstart;
  my $querysub;

  for my $line (@{$res}) {
     chomp($line);
     ($id,$score,$extscore,$fullhit,$querystart,$hitstart) = split(/ /,$line);
     my $motif     = Bio::DOOP::Motif->new($self->{DB},$id);

     push @mofext_res, [$motif,$score,$extscore,$querysub,$fullhit,$querystart,$hitstart];
  }

  return(\@mofext_res);
}

=head2 get_results_from_file

  Returns the arrayref of the array of motif objects and anything else like the get_results
  method  or -1 in case
  of error.
  This is a very uniq method because it is not depend to the object. So you can fetch more
  different results of different mofext objects. Maybe it is going to out from this module
  in the future.

=cut

sub get_results_from_file {
  my $self                 = shift;
  my $filename             = shift;

  my @mofext_res;
  my $id;
  my $score;
  my $extscore;
  my $fullhit;
  my $querystart;
  my $hitstart;
  my $querysub;

  open RES,$filename or return(-1);
  while(<RES>){
     my $line = $_;

     chomp($line);
     ($id,$score,$extscore,$fullhit,$querystart,$hitstart) = split(/ /,$line);
     my $motif     = Bio::DOOP::Motif->new($self->{DB},$id);

     push @mofext_res, [$motif,$score,$extscore,$querysub,$fullhit,$querystart,$hitstart];
  }
  close RES;
  return(\@mofext_res);
}

1;

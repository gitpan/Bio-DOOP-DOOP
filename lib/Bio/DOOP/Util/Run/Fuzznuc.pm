package Bio::DOOP::Util::Run::Fuzznuc;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Util::Run::Fuzznuc - Fuzznuc runner module.

=head1 VERSION

  Version 0.1

=cut

our $VERSION = '0.1';

=head1 SYNOPSIS

#!/usr/bin/perl -w

use Bio::DOOP::DOOP;
$db     = Bio::DOOP::DBSQL->connect("user","pass","doop-plant-1_5","localhost");

@list   = ("81001020","81001110","81001200","81001225","81001230","81001290","81001470","81001580","81001610","81001620","81001680","81001680","81001690","81001725","81001780","81001930","81001950","81002100","81002130","81002140","81002160");

$fuzznuc = Bio::DOOP::Util::Run::Fuzznuc->new($db,'500','M',\@list);

$fuzznuc->set_tmp_file_name("/data/DOOP/dummy.txt");

print $fuzznuc->get_tmp_file_name,"\n";

$error = $fuzznuc->write_to_tmp;

if($error != 0){
   die "Write error!\n";
}

$error = $fuzznuc->run('TTGGGC' , 6 , 0.6 , '/data/default_matrix' );

if ($error == -1){
   die "No results or error!\n";
}

@res = @{$fuzznuc->get_results};


=head1 DESCRIPTION

  This module is a wrapper for the Emboss program fuzznuc. You can search

  patterns in the promoter sequences.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 SUBRUTINES

=head2 new

  

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $subset_type          = shift;
  my $cluster_id_list      = shift;
  my $tmp_filename         = shift;

  if (!$tmp_filename) { $tmp_filename = "/tmp/fuzznuc_run.txt" }
  open TMP,">$tmp_filename";
  for my $cl_id (@{$cluster_id_list}){
     my $cl = Bio::DOOP::Cluster->new($db,,$cl_id,$promo_type);
     my $subset = $cl->get_subset_by_type($subset_type);
     if ($subset == -1){ next }
     my @seqs = @{$subset->get_all_seqs};
     for my $seq (@seqs){
        print TMP ">",$seq->get_id,"\n";
	print TMP $seq->get_raw_seq,"\n\n";
     }
  }
  close TMP;
  $self->{DB}              = $db;
  $self->{CLLIST}          = $cluster_id_list;
  $self->{TMP_FILE}        = $tmp_filename;

  bless $self;
  return($self);
}

=head2 new_by_file

  

=cut

sub new_by_file {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $subset_type          = shift;
  my $filename             = shift;
  my $tmp_filename         = shift;
  my @cluster_id_list;

  if (!$tmp_filename) { $tmp_filename = "/tmp/fuzznuc_run.txt" }

  open CLUSTER_ID_FILE,$filename or cluck("No such file or directory!\n");
  open TMP,">$tmp_filename" or cluck("Can not write to the tmp file!\n");
  while(<CLUSTER_ID_FILE>){
     chomp;
     my $cl_id = $_;
     push @cluster_id_list,$cl_id;
     my $cl = Bio::DOOP::Cluster->new($db,,$cl_id,$promo_type);
     my $subset = $cl->get_subset_by_type($subset_type);
     if ($subset == -1) { next }
     my @seqs = @{$subset->get_all_seqs};
     for my $seq (@seqs){
        print TMP ">",$seq->get_id,"\n";
	print TMP $seq->get_raw_seq,"\n\n";
     }
  }
  close CLUSTER_ID_FILE;
  close TMP;

  $self->{DB}              = $db;
  $self->{CLLIST}          = \@cluster_id_list;
  $self->{TMP_FILE}        = $tmp_filename;

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

=head2 run

  Run mofext on temporary file, containing motifs.
  Arguments: query sequence, wordsize, cutoff, matrix file path.
  Return type: 0 -> success, -1 -> no result or error

=cut

sub run {
  my $self                 = shift;
  my $pattern              = shift;
  my $mismatch             = shift;
  my $complement           = shift;

  my $file = $self->{TMP_FILE};

  my @result = `fuzznuc $file -pattern='$pattern' -pmismatch=$mismatch -complement=$complement -stdout -auto`;

  #FIXME need some parsing module
  my $seq_id;
  my $start;
  my $end;
  my $mism;
  my $hitseq;
  my @parsed;
  for my $line (@result){
     if ($line =~ / Sequence: (\S+)/){
        $seq_id = $1;
     }
     if ($line =~ /\s+(\d+)\s+(\d+) pattern1\s+([1234567890.]+) (.+)/){
        $start  = $1;
	$end    = $2;
	$mism   = $3;
	$hitseq = $4;
	$mism =~ s/\./0/;
	push @parsed,"$seq_id $start $end $mism $hitseq";
     }
  }

  $self->{RESULT} = \@parsed;
  return(\@parsed);
}

=head2 run_background

  Run fuzznuc, but don not wait for the end
  Arguents: query pattern, mismatch, complement, output file name
  Return type: the process id

=cut

sub run_background {
  my $self                 = shift;
  my $pattern              = shift;
  my $mismatch             = shift;
  my $complement           = shift;
  my $outfile              = shift;
  my $file = $self->{TMP_FILE};
  my $pid;

  unless($pid = fork){
     `fuzznuc $file -pattern='$pattern' -pmismatch=$mismatch -complement=$complement -outfile=$outfile`;
  }

  return($pid);
}

=head2 get_results_from_file

  Returns ... or -1 in case
  of error.
  This is a very uniq methods because it is not depend to the object. So you can fetch more
  different results of different mofext objects. Maybe it is going to out from this module
  in the future.

=cut

sub get_results_from_file {
  my $self                 = shift;
  my $filename             = shift;

  my $seq_id;
  my $start;
  my $end;
  my $mism;
  my $hitseq;
  my @parsed;

  open FILE,$filename or return(-1);
  while(<FILE>){
     chomp;
     my $line = $_;
     if ($line =~ / Sequence: (\S+)/){
        $seq_id = $1;
     }
     if ($line =~ /\s+(\d+)\s+(\d+) pattern1\s+([1234567890.]+) (.+)/){
        $start  = $1;
	$end    = $2;
	$mism   = $3;
	$hitseq = $4;
	$mism =~ s/\./0/;
	push @parsed,"$seq_id $start $end $mism $hitseq";
     }
  }
  close FILE;

  $self->{RESULT} = \@parsed;
  return(\@parsed);
}

1;

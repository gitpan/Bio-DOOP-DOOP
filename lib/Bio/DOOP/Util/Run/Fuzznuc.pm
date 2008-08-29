package Bio::DOOP::Util::Run::Fuzznuc;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Util::Run::Fuzznuc - Fuzznuc runner module.

=head1 VERSION

  Version 0.4

=cut

our $VERSION = '0.6';

=head1 SYNOPSIS

#!/usr/bin/perl -w

use Bio::DOOP::DOOP;
$db     = Bio::DOOP::DBSQL->connect("user","pass","doop-plant-1_5","localhost");

@list   = ("81001020","81001110","81001200","81001225","81001230","81001290","81001470","81001580","81001610","81001620","81001680");

$fuzznuc = Bio::DOOP::Util::Run::Fuzznuc->new($db,'500','M',\@list,"/data/DOOP/dummy.txt");

print $fuzznuc->get_tmp_file_name,"\n";

$error = $fuzznuc->run('TTGGGC' , 1 , 0);

if ($error == -1){
   die "No results or error!\n";
}

@res = @{$fuzznuc->get_results};

for $result (@res){
  print $$result[0]->get_id,"| ",$$result[1]," ",$$result[2]," ",$$result[3]," ",$$result[4],"\n";
}

=head1 DESCRIPTION

  This module is a wrapper for the EMBOSS (http://emboss.sourceforge.net) program fuzznuc. You can search
  patterns in the promoter sequences.

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

  $fuzznuc = Bio::DOOP::Util::Run::Fuzznuc->new($db,500,'M',@list,'/tmp/tmpfile');

  Create new Fuzznuc object.

  Arguments :

  Bio::DOOP::DBSQL object
  promoter type (500, 1000, 3000)
  subset type (depends on reference species)
  arrayref of clusters
  temporary file name (default: /tmp/fuzznuc_run.txt)

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $promo_type           = shift;
  my $subset_type          = shift;
  my $cluster_id_list      = shift;
  my $tmp_filename         = shift;

  # TODO use File::Temp module
  if (!$tmp_filename) { $tmp_filename = "/tmp/fuzznuc_run.txt" }
  open TMP,">$tmp_filename";
  for my $cl_id (@{$cluster_id_list}){
     my $cl = Bio::DOOP::Cluster->new($db,,$cl_id,$promo_type);
     if ($cl == -1){ next }
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

  Create new fuzznuc object from query file, containing cluster ids.

  Arguments :
  
  Bio::DOOP::DBSQL object
  promoter type (500, 1000, 3000)
  subset type (depends on reference species)
  file that contain cluster ids
  temporary file name (default: /tmp/fuzznuc_run.txt)

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

  # TODO use File::Temp module
  if (!$tmp_filename) { $tmp_filename = "/tmp/fuzznuc_run.txt" }

  open CLUSTER_ID_FILE,$filename or cluck("No such file or directory!\n");
  open TMP,">$tmp_filename" or cluck("Can't write to the temporary file!\n");
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

=head2 new_by_tmp

  Create new Fuzznuc object from existing temporary file, containing query sequences in fasta format.

  Arguments :

  DBSQL object
  temporary file name

=cut

sub new_by_tmp {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $tmp_filename         = shift;

  $self->{DB}              = $db;
  $self->{TMP_FILE}        = $tmp_filename;
      
  bless $self;
  return($self);
}

=head2 get_tmp_file_name

  Get the temporary file name.

  Return type :

  string

=cut

sub get_tmp_file_name {
  my $self                 = shift;
  return($self->{TMP_FILE});
}

=head2 get_emboss_version

  Get the installed emboss version number.

  $fuzznuc->get_emboss_version

  Return type :

  string

=cut

sub get_emboss_version {
  my $self                 = shift;
  return($self->{EMBOSSVER});
}

=head2 run

  Run fuzznuc on temporary file, containing sequences.

  Arguments :

  query pattern
  mismatch number
  complement (0 or 1)

  Return type :

  0 if success, -1 if no results or error happened

=cut

sub run {
  my $self                 = shift;
  my $pattern              = shift;
  my $mismatch             = shift;
  my $complement           = shift;

  my $file = $self->{TMP_FILE};

  my @result = `fuzznuc $file -pattern='$pattern' -pmismatch=$mismatch -complement=$complement -stdout -auto`;
  
  my $seq_id;
  my $start;
  my $end;
  my $mism;
  my $hitseq;
  my @parsed;
  my $strand;

  if ($#result == -1) { return(-1) } #No results or error happened.
  for my $line (@result){
     if ($line =~ / Sequence: (\S+)/){
        $seq_id = $1;
     }
     if ($line =~ /\s+(\d+)\s+(\d+)\s+(\w+)\s+([0123456789.]+)\s+(\w+)/){
        $start  = $1;
	$end    = $2;
	$mism   = $4;
	$hitseq = $5;
	$mism =~ s/\./0/;
	$strand = $start < $end ? 1 : -1;
	push @parsed, "$seq_id $start $end $mism $hitseq $strand";
     }
  }

  $self->{RESULT} = \@parsed;
  return(0);
}

=head2 run_background

  Run fuzznuc, but do not wait for completion.

  Arguments :

  query pattern
  mismatch number
  complement (0 or 1)
  output filename

  Return type :

  process id

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

=head2 get_results

  Returns an arrayref of arrays of sequence objects.

=cut

sub get_results {
  my $self                = shift;

  my @fuzznuc_res;
  my $res = $self->{RESULT};
  my $seq_id;
  my $start;
  my $end;
  my $mism;
  my $hitseq;
  my $strand;

  for my $line (@{$res}){
     ($seq_id,$start,$end,$mism,$hitseq,$strand) = split(/\s+/,$line);
    
     my $seq = Bio::DOOP::Sequence->new_from_dbid($self->{DB},$seq_id);
     push @fuzznuc_res,[$seq,$start,$end,$mism,$hitseq,$strand];
  }

  return(\@fuzznuc_res);
}

=head2 get_results_from_file

  Returns an arrayref of arrays of sequence objects or -1 if an error happened.

  This is a very unique methods because it does not depend on the object. With it you can fetch
  the results of different fuzznuc objects. Maybe it will go out from the module in the future.

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
  my $strand;

  open FILE, $filename or return(-1);
  while(<FILE>){
     chomp;
     my $line = $_;
     if ($line =~ / Sequence: (\S+)/){
        $seq_id = $1;
     }
     if ($line =~ /\s+(\d+)\s+(\d+)\s+(\w+)\s+([0123456789.]+)\s+(\w+)/){
        $start  = $1;
	$end    = $2;
	$mism   = $4;
	$hitseq = $5;
	$mism =~ s/\./0/;
	$strand = $start < $end ? 1 : -1;
        my $seq = Bio::DOOP::Sequence->new($self->{DB},$seq_id);
	push @parsed, [$seq,$start,$end,$mism,$hitseq,$strand];
     }
  }
  close FILE;

  $self->{RESULT} = \@parsed;
  return(\@parsed);
}

1;

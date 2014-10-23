package Bio::DOOP::Util::Filt;

use strict;
use warnings;

=head1 NAME

  Bio::DOOP::Util::Filt - filter the cluster list.

=head1 VERSION

  Version 0.1

=cut

our $VERSION = '0.1';

=head1 SYNOPSIS

  use Bio::DOOP::DOOP;

  @list = ("81001020","81001110","81001200","80100006");
  $db   = Bio::DOOP::DBSQL->connect("username","passwd","doop-chordate-1_4","localhost");
  $filt = Bio::DOOP::Util::Filt->new_by_list($db,\@list,500);

  @res = @{$filt->filt_by_goid("0046872")};
  for(@res){
    print $_->get_cluster_id,"\n";
  }

=head1 DESCRIPTION

  This object can filtering a cluster list. It is useful to find a smaller list from a
  big mofext or fuzznuc search.

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 SUBRUTINES

=head2 new

  Create new Filter object from Cluster object array.

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $clarray              = shift;
  my $prom                 = shift;

  $self->{CLARRAY}         = $clarray;
  $self->{DB}              = $db;
  $self->{PROM}            = $prom;

  bless $self; 
  return($self);
}

=head2 new_by_list

  Create new Filter class from cluster id array.

=cut

sub new_by_list {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $clarray_id           = shift;
  my $prom                 = shift;
  my @clarray;

  for my $id (@{$clarray_id}){
     my $cl = Bio::DOOP::Cluster->new($db,$id,$prom);
     if ($cl == -1){next}
     push @clarray,$cl;
  }

  $self->{CLARRAY}         = \@clarray;
  $self->{DB}              = $db;
  $self->{PROM}            = $prom;

  bless $self;
  return($self);
}

=head2 new_by_id

  Create new Filter class from cluster primary id array.

=cut

sub new_by_id {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $clarray_id           = shift;
  my @clarray;

  for my $id (@{$clarray_id}){
     my $cl = Bio::DOOP::Cluster->new_by_id($db,$id);
     if ($cl == -1){warn"Missing $id"; next;}
     push @clarray,$cl;
  }

  $self->{CLARRAY}         = \@clarray;
  $self->{DB}              = $db;

  bless $self;
  return($self);
}

=head2 filt_by_goid

  Filter the cluster list by GO id
  @filtered = @{$filt->filt_by_goid("0006523")};

=cut

sub filt_by_goid {
  my $self                 = shift;
  my $goid                 = shift;

  my @cl = @{$self->{CLARRAY}};
  my @ret;

  CLUSTER:for my $cl (@cl){
     my @seqs = @{$cl->get_all_seqs};
     for my $seq (@seqs){
        my $goids = $seq->get_xref_value("go_id");
        if ($goids == -1){next}
        for my $id (@{$goids}){
           if ($id eq $goid){
              push @ret,$cl;
              next CLUSTER;
           }
        }
     }
  }

  return(\@ret);
}

1;

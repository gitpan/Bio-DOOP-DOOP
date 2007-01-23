package Bio::DOOP::DOOP;

use strict;
use warnings;
use Bio::DOOP::DBSQL;
use Bio::DOOP::Cluster;
use Bio::DOOP::ClusterSubset;
use Bio::DOOP::Sequence;
use Bio::DOOP::SequenceFeature;
use Bio::DOOP::Motif;
use Bio::DOOP::Util::Search;
use Bio::DOOP::Graphics::Feature;

=head1 NAME

  Bio::DOOP::DOOP - DOOP API main module

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

  use Bio::DOOP::DOOP;

  $db = Bio::DOOP::DBSQL->new("doopuser","dooppass","doop_1_5","localhost");
  $cluster = Bio::DOOP::Cluster->new($db,"8010109","500");
  @seqs = @{$cluster->get_all_seqs};
  foreach $seq (@seqs){
     print $seq->seq,"\n";
  }

=head1 DESCRIPTION

  DOOP is a database containing orthologous clusters of promoters from Homo sapiens, 
  Arabidopsis thaliana and other organisms. Visit the http://doop.abc.hu/ for more 
  information.
  This is a container module for all the DOOP modules.
  You can simply use this module to access all DOOP objects.
  For more help, please see the documentation of the individual
  objects.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 OBJECTS

=head2 Bio::DOOP::DBSQL

  Object for simple SQL querys

=head2 Bio::DOOP::Cluster

  Object for the clusters

=head2 Bio::DOOP::ClusterSubset

  Object for the set of sequences that is smaller (or equal) than the cluster itself.

=head2 Bio::DOOP::Sequence

  Object for the cluster (or cluster subset) sequences.

=head2 Bio::DOOP::SequenceFeature

  Object for the special annotation of the sequences.

=head2 Bio::DOOP::Motif

  Object for the conserved regulatory elements.

=head2 Bio::DOOP::Util::Search

  Module for some useful searching subrutine.

=cut

=head1 COPYRIGHT & LICENSE

Copyright 2006 Tibor Nagy, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

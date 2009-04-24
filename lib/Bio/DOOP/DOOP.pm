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
use Bio::DOOP::Util::Sort;
use Bio::DOOP::Util::Filt;
use Bio::DOOP::Util::Run::Mofext;
use Bio::DOOP::Util::Run::Fuzznuc;
use Bio::DOOP::Util::Run::GeneMerge;
use Bio::DOOP::Util::Run::Admin;
use Bio::DOOP::Graphics::Feature;

=head1 NAME

  Bio::DOOP::DOOP - DOOP API main module

=head1 VERSION

Version 1.02

=cut

our $VERSION = '1.02';

=head1 SYNOPSIS

  use Bio::DOOP::DOOP;

  # to connect to the primary database uncomment the following lines
  # $user = "promoter";
  # $pass = "sql04CP";
  # $database = "doop-chordate-1_4"; # for vertebratas
  # $database = "doop-plant-1_6"; # for plants
  # $host = "bioweb.abc.hu";

  $db = Bio::DOOP::DBSQL->connect($user,$pass,$database,$host);
  $cluster = Bio::DOOP::Cluster->new($db,"8010109","500");
  @seqs = @{$cluster->get_all_seqs};
  foreach $seq (@seqs){
     print $seq->seq,"\n";
  }

=head1 DESCRIPTION

  DoOP is a database containing orthologous clusters of promoters from Homo sapiens, 
  Arabidopsis thaliana and other organisms. Visit the http://doop.abc.hu/ site for
  more information or read the following article.

  Endre Barta, Endre Sebestyén, Tamás B. Pálfy, Gábor Tóth, Csaba P. Ortutay, and László Patthy
  DoOP: Databases of Orthologous Promoters, collections of clusters of orthologous upstream 
  sequences from chordates and plants
  Nucl. Acids Res. 2005, Vol 33, Database issue D86-D90

  This is a container module for all of the DOOP modules.
  You can simply use this module to access all DOOP objects.
  For more help, please see the documentation of the individual
  objects.

  If you would like to connect to the database of Agricultural Biotechnology Center,
  you can use the following syntax:

  Bio::DOOP::DBSQL->connect("promoter", "sql04CP", "doop-choordate-1_4", "bioweb.abc.hu");

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 OBJECTS

=head2 Bio::DOOP::DBSQL

  Object for simple SQL queries. Use it to connect to the database.
  This is the first module you should use.

=head2 Bio::DOOP::Cluster

  Object for the clusters. Cluster is a homologue promoter collection.

=head2 Bio::DOOP::ClusterSubset

  Object for the subsets of sequences in a cluster.

=head2 Bio::DOOP::Sequence

  Object for the sequences.

=head2 Bio::DOOP::SequenceFeature

  Object for the different features of a sequence.

=head2 Bio::DOOP::Motif

  Object for the conserved sequence features.

=head2 Bio::DOOP::Util::Search

  Module for different search subrutines.

=head2 Bio::DOOP::Util::Sort

  Sort an array of array by given conditions.

=head2 Bio::DOOP::Util::Filt

  Filter a cluster array by given conditions.

=head2 Bio::DOOP::Util::Run::Mofext

  MOFEXT wrapper. MOFEXT is a motif search 
  tool developed by the author Tibor Nagy.

=head2 Bio::DOOP::Util::Run::Fuzznuc

  FUZZNUC wrapper. Install Emboss to use this.

=head2 Bio::DOOP::Util::Run::GeneMerge

 GeneOntology analyzer, based on the program
 GeneMerge.

=head2 Bio::DOOP::Util::Run::Admin

  Module for controlling the Mofext, Fuzznuc wrapper processes.

=head2 Bio::DOOP::Graphics::Feature

  Module for generating a picture of the sequences and features of a cluster.

=cut

=head1 COPYRIGHT & LICENSE

Copyright 2009 Tibor Nagy, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

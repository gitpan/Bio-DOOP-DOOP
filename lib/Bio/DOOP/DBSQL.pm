package Bio::DOOP::DBSQL;

use strict;
use warnings;
use DBI;

=head1 NAME

  Bio::DOOP::DBSQL - MySQL control object

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

  $db  = Bio::DOOP::DBSQL->connect("doopuser","dooppass","database","localhost");
  $res = $db->query("SELECT * FROM sequence LIMIT 10");
  foreach (@$res) {
     @fields = @{$_};
     print "@fields\n";
  }

=head1 DESCRIPTION

  This object provides low level access to the MySQL database. In most
  cases you do not need to use it, because the DOOP API handles the database
  queries. Still if you need some special query and the DOOP 
  API can't help you, use the query method to access the database.

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 connect

  $db = Bio::DOOP::DBSQL->connect("doopuser","dooppass","database","localhost");

  You can connect to the database with this method. The arguments are the 
  following : username, password, database name, host. The return value
  is a Bio::DOOP::DBSQL object. You must use this object in the argument
  of other objects.

=cut

sub connect {
  my $self                 = {};
  my $dummy                = shift;
     $self->{USER}         = shift;
     $self->{PASS}         = shift;
     $self->{DATABASE}     = shift;
     $self->{HOST}         = shift;

  my $host                 = $self->{HOST};
  my $db                   = $self->{DATABASE};

  $self->{DB} = DBI->connect("dbi:mysql:$db:$host",$self->{USER},$self->{PASS});

  bless $self;
  return ($self);
}

=head2 query

  $db->query("SELECT COUNT(*) FROM Cluster;");

  You can run special SQL statements on the database. In this example we count
  the number of clusters.
  Returns an arrayref to the results.

=cut

sub query {
  my $self = shift;
  my $q    = shift;

  my $sth  = $self->{DB}->prepare($q);
  $sth->execute();
  my $results = $sth->fetchall_arrayref();

  return($results);
}

1;

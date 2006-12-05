package Bio::DOOP::DBSQL;

use strict;
use warnings;
use DBI;

=head1 NAME

  Bio::DOOP::DBSQL - MySQL control object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head2 SYNOPSIS

  $db  = Bio::DOOP::DBSQL->connect("doopuser","dooppass","doop-plant-1_5","localhost");
  $res = $db->query("SELECT * FROM sequence LIMIT 10");
  foreach (@$res){
     @fields = @{$_};
     print"@fields\n";
  }

=head2 DESCRIPTION

  This object is a low level access to the MySQL database. Most of
  the cases you would not need to use because the DOOP API is substitute
  the database manipulations. But if you need special query from the
  database and the DOOP API can not help you, you can make a query with
  the query method.

=head2 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head2 METHODS

=head1 connect

  You can connect to the database. The arguments is the following:
  user name, password, database name, database host. The return value
  is a Bio::DOOP::DBSQL object. You must use this objects in the argument
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

=head1 query

  You can run special SQL statements on the database. The 
  return is an arrayref to the results.

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

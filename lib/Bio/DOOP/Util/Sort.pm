package Bio::DOOP::Util::Sort;

use strict;
use warnings;

=head1 NAME

  Bio::DOOP::Util::Sort - sort an array of arrays.

=head1 VERSION

  Version 0.2

=cut

our $VERSION = '0.2';

=head1 SYNOPSIS

  @result = $mofext->get_results;
  $sorting = Bio::DOOP::Util::Sort->new($db,\results);
  @sorted_result = $sorting->sort_by_column(1,"asc"); 

=head1 DESCRIPTION

  This class can sort any type of array of arrays. It can be used to sort the
  mofext or fuzznuc results, but can sort other data.

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

  $mofext_sort = Bio::DOOP::Util::Sort->new($db,\@mofext_result);

  Create a Sort class.
  Arguments: Bio::DOOP::DBSQL, array of array (practically it is a table)

=cut

sub new {
   my $self                = {};
   my $dummy               = shift;
   my $db                  = shift;
   my $array               = shift;

   $self->{ARRAY}          = $array;
   $self->{DB}             = $db;

   bless $self;
   return($self);
}

=head2 sort_by_column

  @ret = $mofext_sort->sort_by_column(0,"asc");

  Sort a given array by column. (Warning, the first column is zero!)
  Return type: sorted array of arrays

=cut

sub sort_by_column {
   my $self                = shift;
   my $column              = shift;
   my $orient              = shift;
   my @ret;
   
   if( ($orient eq "1") || ($orient eq "asc") || ($orient eq "ascendent")){
       @ret = sort { $$a[$column] <=> $$b[$column] } @{$self->{ARRAY}};
   }
   else{
       @ret = sort { $$b[$column] <=> $$a[$column] } @{$self->{ARRAY}};
   }

   
}
1;

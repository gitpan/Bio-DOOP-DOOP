package Bio::DOOP::Util::Run::Admin;

use strict;
use warnings;
use Proc::ProcessTable;

=head1 NAME

Bio::DOOP::Util::Run::Admin - Manage the running mofext or fuzznuc processes

=head1 VERSION

Version 0.3

=cut

our $VERSION = '0.3';

=head1 SYNOPSIS

=head1 DESCRIPTION

This class manages the Run objects (Bio::DOOP::Run::Mofext and Bio::DOOP::Run::Fuzznuc).

=head1 AUTHORS

Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

Creates a new Admin class.

Return type: Bio::DOOP::Util::Run::Admin object

  $admin = Bio::DOOP::Util::Run::Admin->new;

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my @doop_pids;

  my $table = new Proc::ProcessTable;
  $self->{TABLE} = $table;

  # Store only mofext and fuzznuc process ids.
  for my $p (@{$table}){
     if( ($p->cmndline =~ /mofext/) || ($p->cmndline =~ /fuzznuc/) ){
        push @doop_pids,$p->pid;
     }
  }
  $self->{PIDS} = \@doop_pids;

  bless $self;
  return($self);
}

=head2 get_run_pids

Returns the arrayref of running pids.

  for my $i (@{$admin->get_run_pids}){
     $admin->kill($i,9);
  }

=cut

sub get_run_pids {
  my $self                 = shift;
  return($self->{PIDS});
}

=head2 kill

Sends specified signal to a process given by the first arguments.

Return type: none

  $admin->kill(1234,SIGINT);

=cut

sub kill {
  my $self                 = shift;
  my $pid                  = shift;
  my $signal               = shift;

  for my $process (@{$self->{TABLE}}){
     if ($process->pid == $pid){
        $process->kill($signal);
     }
  }
}

=head2 nice

Sets the priority of the process.

Return type: none

  $admin->nice(1234,19);

=cut

sub nice {
  my $self                 = shift;
  my $pid                  = shift;
  my $priority             = shift;

  for my $process (@{$self->{TABLE}}){
     if ($process->pid == $pid){
        $process->priority($priority);
     }
  }
}

1;

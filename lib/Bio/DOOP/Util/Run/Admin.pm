package Bio::DOOP::Util::Run::Admin;

use strict;
use warnings;
use Proc::ProcessTable;

=head1 NAME

  Bio::DOOP::Util::Run::Admin - Manage the running mofext or fuzznuc processes.

=head1 VERSION

  Version 0.2

=cut

our $VERSION = '0.2';

=head1 SYNOPSIS

=head1 DESCRIPTION

  This class manages the Run objects (Run::Mofext and Run::Fuzznuc).

=head1 AUTHORS

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

  $admin = Bio::DOOP::Util::Run::Admin->new;

  Create a new Admin class.

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

  for my $i (@{$admin->get_run_pids}){
     $admin->kill($i,9);
  }

  Returns the arrayref of running pids.

=cut

sub get_run_pids {
  my $self                 = shift;
  return($self->{PIDS});
}

=head2 kill

  $admin->kill(1234,SIGINT);

  Send specified signal to a process given by the first arguments.

  Return type :

  none

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

  $admin->nice(1234,19);

  Set the priority of the process.

  Return type :

  none

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

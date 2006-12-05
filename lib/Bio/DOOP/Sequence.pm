package Bio::DOOP::Sequence;

use strict;
use warnings;
use Bio::DOOP::DBSQL;
use Bio::DOOP::SequenceFeature;

=head1 NAME

  Bio::DOOP::Sequence - Promoter sequence object

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 DESCRIPTION

  This object represent the promoters in the database.
  You can access the different annotation through this
  object.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary

=head1 METHODS

=head2 new

  $seq = Bio::DOOP::Sequence->new($db,"1234");
  The arguments is the following: Bio::DOOP::DBSQL object, primary id

=cut

sub new {
  my $self                 = {};
  my $dummy                = shift;
  my $db                   = shift;
  my $id                   = shift;
  my $i;
  my $ret = $db->query("SELECT * FROM sequence WHERE sequence_primary_id = $id;");
  my @fields = @{$$ret[0]};

  $self->{DB}              = $db;
  $self->{PRIMARY}         = $fields[0];
  $self->{FAKE}            = $fields[1];
  $self->{DB_ID}           = $fields[2];
  $self->{LENGTH}          = $fields[3];
  $self->{DATE}            = $fields[4];
  $self->{VERSION}         = $fields[5];
  $self->{ANNOT}           = $fields[6];
  $self->{ORIG}            = $fields[7];
  $self->{DATA}            = $fields[8];
  $self->{TAXON}           = $fields[9];

  if ($self->{ANNOT} ne ""){

  $ret = $db->query("SELECT * FROM sequence_annot WHERE sequence_annot_primary_id = ".$self->{ANNOT}.";");
  @fields = @{$$ret[0]};

  $self->{MAINDBID}        = $fields[1];
  $self->{UTR}             = $fields[2];
  $self->{DESC}            = $fields[3];
  $self->{GENENAME}        = $fields[4];

  }

  $ret = $db->query("SELECT * FROM sequence_data WHERE sequence_data_primary_id =".$self->{DATA}.";");
  @fields = @{$$ret[0]};

  $self->{FASTA}           = $fields[2];
  $self->{BLAST}           = $fields[3];

  $ret = $db->query("SELECT * FROM taxon_annotation WHERE taxon_primary_id =".$self->{TAXON}.";");
  @fields = @{$$ret[0]};

  $self->{TAXID}           = $fields[1];
  $self->{TAXNAME}         = $fields[2];
  $self->{TAXCLASS}        = $fields[3];

  my %xref;
  $ret = $db->query("SELECT xref_id,xref_type FROM sequence_xref WHERE sequence_primary_id = $id;");
  for($i = 0; $i < $#$ret+1; $i++){
	  @fields = @{$$ret[$i]};
	  push @{ $xref{$fields[1]} }, $fields[0];
  }
  $self->{XREF}            = \%xref;

  bless $self;
  return($self);
}

=head2 get_id

  Return the sequence primary id. It is the MySQL id

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_fake_id

  Return the fake gi.

=cut

sub get_fake_id {
  my $self                 = shift;
  return($self->{FAKE});
}

=head2 get_db_id

  Return the data primary id. Is is used by the MySQL querys and it is the header of the subset FASTA file

=cut

sub get_db_id {
  my $self                 = shift;
  return($self->{DB_ID});
}

=head2 get_length

  Return the length of the sequence

=cut

sub get_length {
  my $self                 = shift;
  return($self->{LENGTH});
}

=head2 get_date

  Return the modification date of the MySQL record

=cut

sub get_date {
  my $self                 = shift;
  return($self->{DATE});
}

=head2 get_ver

  Return the version of the sequence

=cut

sub get_ver {
  my $self                 = shift;
  return($self->{VERSION});
}

=head2 get_annot_id

  Return the annotation primary id. Is is used by the MySQL querys

=cut

sub get_annot_id {
  my $self                 = shift;
  return($self->{ANNOT});
}

=head2 get_orig_id

  This is not yet used

=cut

sub get_orig_id {
  my $self                 = shift;
  return($self->{ORIG});
}

=head2 get_data_id

  Return the sequence data primary id. Is is used by the MySQL querys

=cut

sub get_data_id {
  my $self                 = shift;
  return($self->{DATA});
}

=head2 get_taxon_id

  Return the taxon annotiation primary id. Is is used by the MySQL querys

=cut

sub get_taxon_id {
  my $self                 = shift;
  return($self->{TAXON});
}

=head2 get_data_main_db_id

  Return the sequence annotation data primary id. Is is used by the MySQL querys

=cut

sub get_data_main_db_id {
  my $self                 = shift;
  return($self->{MAINDBID});
}

=head2 get_utr_length

  $utr_length = $seq->get_utr_length;
  Return the length of the UTR contained by the sequence.

=cut

sub get_utr_length {
  my $self                 = shift;
  return($self->{UTR});
}

=head2 get_desc

  print $seq->get_desc,"\n";
  Print out the sequence description. Contain useful informations
  from the sequence.

=cut

sub get_desc {
  my $self                 = shift;
  return($self->{DESC});
}

=head2 get_gene_name

  $gene_name = $seq->get_gene_name;
  Return the gene name of the promoter. If the gene is
  unknow or not annotated, it is empty

=cut

sub get_gene_name {
  my $self                 = shift;
  return($self->{GENENAME});
}

=head2 get_fasta

  print $seq->get_fasta;
  Print out the promoter sequence in FASTA format

=cut

sub get_fasta {
  my $self                 = shift;
  my $seq = ">".$self->{DB_ID}."\n".$self->{FASTA};
  return($seq);
}

=head2 get_blast

  print $seq->get_blast;
  Print out the Blast result

=cut

sub get_blast {
  my $self                 = shift;
  return($self->{BLAST});
}

=head2 get_taxid

  $taxid = $seq->get_taxid;
  Return the NCBI taxid of the sequence

=cut

sub get_taxid {
  my $self                 = shift;
  return($self->{TAXID});
}

=head2 get_taxon_name

  print $seq->get_taxon_name;
  Print out the taxon name of the sequence

=cut

sub get_taxon_name {
  my $self                 = shift;
  return($self->{TAXNAME});
}

=head2 get_taxon_class

  print $seq->get_taxon_class;
  Print out the taxonomical class (most of the cases it is the family)
  of the species of the sequence

=cut

sub get_taxon_class {
  my $self                 = shift;
  return($self->{TAXCLASS});
}

=head2 print_all_xref

  $seq->print_all_xref;
  Print out all the alternative database connections. It is contain
  the GO id, NCBI RNA GI and so on. You use this method for debug your database.

=cut

sub print_all_xref {
  my $self                 = shift;
  for my $keys ( keys %{ $self->{XREF} }){
	  print"$keys: ";
	  for (@{ ${ $self->{XREF} }{$keys} }){print "$_ "}
	  print"\n";
  }
}

=head2 get_all_xref_keys

  @keys = @{$seq->get_all_xref_keys};
  Return the arrayref of the alternative database names

=cut

sub get_all_xref_keys {
  my $self                 = shift;

  my @xrefkeys = keys %{ $self->{XREF} };
  return(\@xrefkeys);
}

=head2 get_xref_value

  @values = @{$seq->get_xref_value("go_id")};
  Return the arrayref of the values that contains the specified database name

=cut

sub get_xref_value {
  my $self                 = shift;
  my $key                  = shift;

  return(${ $self->{XREF} }{$key});
}

=head2 get_all_seq_features

  @seqfeat = @{$seq->get_all_seq_features};
  Return the arrayref of all sequence features

=cut

sub get_all_seq_features {
  my $self                 = shift;
  
  my @seqfeatures;

  # The order by setting is important for the correct motif drawing
  my $query = "SELECT sequence_feature_primary_id FROM sequence_feature WHERE sequence_primary_id =".$self->{PRIMARY}." ORDER BY feature_start;";
  my $ref = $self->{DB}->query($query);

  for my $sfpid (@$ref){
	  my $sf = Bio::DOOP::SequenceFeature->new($self->{DB},$$sfpid[0]);
	  push @seqfeatures, $sf;
  }

  return(\@seqfeatures);
}


1;

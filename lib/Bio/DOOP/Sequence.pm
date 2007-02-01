package Bio::DOOP::Sequence;

use strict;
use warnings;
use Carp qw(cluck carp verbose);

=head1 NAME

  Bio::DOOP::Sequence - promoter sequence object

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';

=head1 SYNOPSIS

=head1 DESCRIPTION

  This object represents a specific promoter in the database.
  You can access the annotation and the sequence through this object.

=head1 AUTHOR

  Tibor Nagy, Godollo, Hungary and Endre Sebestyen, Martonvasar, Hungary

=head1 METHODS

=head2 new

  $seq = Bio::DOOP::Sequence->new($db,"1234");
  The arguments are the following : Bio::DOOP::DBSQL object, sequence_primary_id

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

  if (defined($self->{ANNOT})){

     $ret = $db->query("SELECT * FROM sequence_annot WHERE sequence_annot_primary_id = ".$self->{ANNOT}.";");
     @fields = @{$$ret[0]};

     $self->{MAINDBID}        = $fields[1];
     $self->{UTR}             = $fields[2];
     $self->{DESC}            = $fields[3];
     $self->{GENENAME}        = $fields[4];

  }
  else {
     cluck"No annotation is available for this promoter sequence! You are on your own now.\n";
  }

  if (defined($self->{DATA})) {
     $ret = $db->query("SELECT * FROM sequence_data WHERE sequence_data_primary_id =".$self->{DATA}.";");
     @fields = @{$$ret[0]};

     $self->{FASTA}           = $fields[2];
     $self->{BLAST}           = $fields[3];
  }
  else {
     cluck"No sequence data available! Where did it go?\n";
  }

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

  Returns the sequence primary id. This is the internal ID from the MySQL database.

=cut

sub get_id {
  my $self                 = shift;
  return($self->{PRIMARY});
}

=head2 get_fake_id

  Returns the sequence fake GI.

=cut

sub get_fake_id {
  my $self                 = shift;
  return($self->{FAKE});
}

=head2 get_db_id

  Returns the full sequence ID.

=cut

sub get_db_id {
  my $self                 = shift;
  return($self->{DB_ID});
}

=head2 get_length

  Returns the length of the sequence.

=cut

sub get_length {
  my $self                 = shift;
  return($self->{LENGTH});
}

=head2 get_date

  Returns the modification date of the MySQL record.

=cut

sub get_date {
  my $self                 = shift;
  return($self->{DATE});
}

=head2 get_ver

  Returns the version of the sequence.

=cut

sub get_ver {
  my $self                 = shift;
  return($self->{VERSION});
}

=head2 get_annot_id

  Returns the sequence annotation primary id. This is the internal ID from the MySQL database.

=cut

sub get_annot_id {
  my $self                 = shift;
  return($self->{ANNOT});
}

=head2 get_orig_id

  This method is not yet implemented.

=cut

sub get_orig_id {
  my $self                 = shift;
  return($self->{ORIG});
}

=head2 get_data_id

  Returns the sequence data primary id. This is the internal ID from the MySQL database.

=cut

sub get_data_id {
  my $self                 = shift;
  return($self->{DATA});
}

=head2 get_taxon_id

  Returns the taxon annotation primary id. This is the internal ID from the MySQL database.

=cut

sub get_taxon_id {
  my $self                 = shift;
  return($self->{TAXON});
}

=head2 get_data_main_db_id

  Returns the sequence annotation primary id. This is the internal ID from the MySQL database.

=cut

sub get_data_main_db_id {
  my $self                 = shift;
  return($self->{MAINDBID});
}

=head2 get_utr_length

  $utr_length = $seq->get_utr_length;
  Returns the length of the 5' UTR included in the sequence.

=cut

sub get_utr_length {
  my $self                 = shift;
  return($self->{UTR});
}

=head2 get_desc

  print $seq->get_desc,"\n";
  Returns the description of the sequence.

=cut

sub get_desc {
  my $self                 = shift;
  return($self->{DESC});
}

=head2 get_gene_name

  $gene_name = $seq->get_gene_name;
  Returns the gene name of the promoter. If the gene is
  unknow or not annotated, it is empty.

=cut

sub get_gene_name {
  my $self                 = shift;
  return($self->{GENENAME});
}

=head2 get_fasta

  print $seq->get_fasta;
  Returns the promoter sequence in FASTA format.

=cut

sub get_fasta {
  my $self                 = shift;
  my $seq = ">".$self->{DB_ID}."\n".$self->{FASTA}."\n";
  return($seq);
}

=head2 get_raw_seq

  Returns the raw sequence without any other identifier
  Return type: string

=cut

sub get_raw_seq {
  my $self                 = shift;
  my $seq = $self->{FASTA};
  return($seq);
}

=head2 get_blast

  print $seq->get_blast;
  This method is not yet implemented.

=cut

sub get_blast {
  my $self                 = shift;
  return($self->{BLAST});
}

=head2 get_taxid

  $taxid = $seq->get_taxid;
  Returns the NCBI taxon ID of the sequence.

=cut

sub get_taxid {
  my $self                 = shift;
  return($self->{TAXID});
}

=head2 get_taxon_name

  print $seq->get_taxon_name;
  Returns the scientific name of the sequence's taxon ID.

=cut

sub get_taxon_name {
  my $self                 = shift;
  return($self->{TAXNAME});
}

=head2 get_taxon_class

  print $seq->get_taxon_class;
  Returns the taxonomic class of the sequence's taxon ID.
  Used internally, to create monophyletic sets of sequences
  in an orthologous cluster.

=cut

sub get_taxon_class {
  my $self                 = shift;
  return($self->{TAXCLASS});
}

=head2 print_all_xref

  $seq->print_all_xref;
  Prints all the xrefs to other databases.
  Type of xref IDs : 
  go_id            : Gene Ontology ID
  ncbi_gene_id     : NCBI gene ID
  ncbi_cds_gi      : NCBI CDS GI
  ncbi_rna_gi      : NCBI RNA GI
  ncbi_cds_prot_id : NCBI CDS protein ID
  ncbi_rna_tr_id   : NCBI RNA transcript ID
  at_no            : At Number

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
  Returns the arrayref of xref names.

=cut

sub get_all_xref_keys {
  my $self                 = shift;

  my @xrefkeys = keys %{ $self->{XREF} };
  return(\@xrefkeys);
}

=head2 get_xref_value

  @values = @{$seq->get_xref_value("go_id")};
  Returns the arrayref of a given xref's values'.

=cut

sub get_xref_value {
  my $self                 = shift;
  my $key                  = shift;

  return(${ $self->{XREF} }{$key});
}

=head2 get_all_seq_features

  @seqfeat = @{$seq->get_all_seq_features};
  Returns the arrayref of all sequence features.

=cut

sub get_all_seq_features {
  my $self                 = shift;
  
  my @seqfeatures;

  # The order of the sequence features is important to correctly draw the picture of the cluster.
  my $query = "SELECT sequence_feature_primary_id FROM sequence_feature WHERE sequence_primary_id =".$self->{PRIMARY}." ORDER BY feature_start;";
  my $ref = $self->{DB}->query($query);

  if ($#$ref == -1){
     cluck"No sequence feature found!\n";
     return();
  }

  for my $sfpid (@$ref){
	  my $sf = Bio::DOOP::SequenceFeature->new($self->{DB},$$sfpid[0]);
	  push @seqfeatures, $sf;
  }

  return(\@seqfeatures);
}

=head2 get_all_subsets

  Returns the subset containing the sequence.

=cut

sub get_all_subsets {
  my $self                 = shift;

  my @subsets;

  my $id    = $self->{PRIMARY};
  my $query = "SELECT subset_primary_id FROM subset_xref WHERE sequence_primary_id = $id";
  my $ref   = $self->{DB}->query($query);

  if ($#$ref == -1){
     cluck"No subset found! This is impossible!!\n";
     return();
  }

  for my $subset (@$ref){
     push @subsets, Bio::DOOP::ClusterSubset->new($self->{DB},$$subset[0]);
  }

  return(\@subsets);
}

1;

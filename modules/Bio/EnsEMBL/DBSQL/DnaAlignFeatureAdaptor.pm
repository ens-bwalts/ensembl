#
# BioPerl module for Bio::EnsEMBL::DBSQL::DnaAlignFeatureAdaptor
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::EnsEMBL::DBSQL::DnaAlignFeatureAdaptor - Adaptor for DnaAlignFeatures

=head1 SYNOPSIS

    $pfadp = $dbadaptor->get_DnaAlignFeatureAdaptor();

    my @feature_array = $pfadp->fetch_by_contig_id($contig_numeric_id);

    my @feature_array = $pfadp->fetch_by_assembly_location($start,$end,$chr,'UCSC');
 
    $pfadp->store($contig_numeric_id,@feature_array);


=head1 DESCRIPTION


This is an adaptor for DNA features on DNA sequence. Like other
feature getting adaptors it has a number of fetch_ functions and a
store function.


=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

Describe contact details here

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::EnsEMBL::DBSQL::DnaAlignFeatureAdaptor;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::EnsEMBL::Root

use Bio::EnsEMBL::DnaDnaAlignFeature;
use Bio::EnsEMBL::DBSQL::BaseAlignFeatureAdaptor;

@ISA = qw(Bio::EnsEMBL::DBSQL::BaseAlignFeatureAdaptor);


sub _tablename {
  my $self = shift;

  return "dna_align_feature";
}

sub _columns {
  my $self = shift;

  return qw(dna_align_feature_id contig_id analysis_id contig_start 
	    contig_end contig_strand hit_start hit_name hit_strand phase
	    cigar_line evalue perc_ident score);
}


=head2 store
 Title   : store
 Usage   :
 Function:
 Example :
 Returns : 
 Args    :


=cut

sub store {
  my ($self,$contig_id,@sf) = @_;
  my $tablename = $self->_tablename();
  
  if( scalar(@sf) == 0 ) {
    $self->throw("Must call store with contig_id then sequence features");
  }
  
  if( $contig_id !~ /^\d+$/ ) {
    $self->throw("Contig_id must be a number, not [$contig_id]");
  }
  
  my $sth = $self->prepare("
     INSERT INTO $tablename (contig_id, contig_start, contig_end,
                             contig_strand, hit_start, hit_end,
                             hit_strand, hit_name, cigar_line,
                             analysis_id, score, evalue, perc_ident) 
     VALUES (?,?,?,?,?,?,?,?,?,?,?, ?, ?)");

  foreach my $sf ( @sf ) {
    if( !ref $sf || !$sf->isa("Bio::EnsEMBL::DnaDnaAlignFeature") ) {
      $self->throw("feature must be an Ensembl DnaDnaAlignFeature, not a [$sf]");
    }

  if( !defined $sf->analysis ) {
    $self->throw("Cannot store sequence features without analysis");
  }
    if( !defined $sf->analysis->dbID ) {
      # maybe we should throw here. Shouldn't we always have an analysis from the database?
      $self->throw("I think we should always have an analysis object which has originated from the database. No dbID, not putting in!");
    }
    #print STDERR "storing ".$sf->gffstring."\n";
    $sth->execute( $contig_id, $sf->start, $sf->end, $sf->strand,
		   $sf->hstart, $sf->hend, $sf->hstrand, $sf->hseqname,
		   $sf->cigar_string, $sf->analysis->dbID, $sf->score, 
		   $sf->p_value, $sf->percent_id);
    $sf->dbID($sth->{'mysql_insertid'});
  }
}



sub _obj_from_hashref {
  my ($self,$hashref) = @_;

  my $rca = $self->db()->get_RawContigAdaptor();
  my $contig = $rca->fetch_by_dbID($hashref->{'contig_id'});
 
  my $aa = $self->db()->get_AnalysisAdaptor();

  my $analysis = $aa->fetch_by_dbID($hashref->{'analysis_id'});

  my $f1 = Bio::EnsEMBL::SeqFeature->new();
  my $f2 = Bio::EnsEMBL::SeqFeature->new();

  $f1->start($hashref->{'contig_start'});
  $f1->end($hashref->{'contig_end'});
  $f1->strand($hashref->{'contig_strand'});
  $f1->score($hashref->{'score'});
  $f1->percent_id($hashref->{'perc_ident'});
  $f1->p_value($hashref->{'evalue'});
  $f1->seqname($contig->name());
  $f1->attach_seq($contig);

  $f2->start($hashref->{'hit_start'});
  $f2->end($hashref->{'hit_end'});
  $f2->strand($hashref->{'hit_strand'});
  $f2->percent_id($hashref->{'perc_ident'});
  $f2->p_value($hashref->{'evalue'});
  $f2->seqname($hashref->{'hit_name'});

  $f1->analysis($analysis);
  $f2->analysis($analysis);

  my $cigar = $hashref->{'cigar_line'};

  my $align_feat = 
    Bio::EnsEMBL::DnaDnaAlignFeature->new( -cigar_string => $cigar, 
					   -feature1 => $f1, 
					   -feature2 => $f2);

  
  #set the 'id' of the feature to the hit name
  $align_feat->id($hashref->{'hit_name'});

  $align_feat->dbID($hashref->{'dna_align_feature_id'});

  return $align_feat;
}


    
1;



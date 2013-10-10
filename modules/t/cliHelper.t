use strict;
use warnings;

use Test::More;
use Bio::EnsEMBL::DBEntry;
use Bio::EnsEMBL::Operon;
use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::Test::TestUtils;
use Bio::EnsEMBL::Utils::CliHelper;
debug("Startup test");
ok(1);

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new();

my $dba = $multi->get_DBAdaptor("core");

debug("Test database instatiated");
ok($dba);

my $cli_helper = Bio::EnsEMBL::Utils::CliHelper->new();

debug("Checking default options");
my $opts = { host   => $dba->dbc()->host(),
             user   => $dba->dbc()->username(),
             pass   => $dba->dbc()->password(),
             port   => $dba->dbc()->port(),
             dbname => $dba->dbc()->dbname(), };

my $dba_args = $cli_helper->get_dba_args_for_opts($opts);

is( scalar(@$dba_args),        1 );
is( $dba_args->[0]->{-HOST},   $opts->{host} );
is( $dba_args->[0]->{-USER},   $opts->{user} );
is( $dba_args->[0]->{-PASS},   $opts->{pass} );
is( $dba_args->[0]->{-PORT},   $opts->{port} );
is( $dba_args->[0]->{-DBNAME}, $opts->{dbname} );
ok( !defined $dba_args->[0]->{-SPECIES} );
ok( !defined $dba_args->[0]->{-SPECIES_ID} );
is( $dba_args->[0]->{-MULTISPECIES_DB}, 0 );

$opts->{species_id} = 1;
$opts->{species} = "homo_sapiens";
$dba_args = $cli_helper->get_dba_args_for_opts($opts);

is( scalar(@$dba_args),        1 );
is( $dba_args->[0]->{-HOST},   $opts->{host} );
is( $dba_args->[0]->{-USER},   $opts->{user} );
is( $dba_args->[0]->{-PASS},   $opts->{pass} );
is( $dba_args->[0]->{-PORT},   $opts->{port} );
is( $dba_args->[0]->{-DBNAME}, $opts->{dbname} );
is( $dba_args->[0]->{-SPECIES}, $opts->{species} );
is( $dba_args->[0]->{-SPECIES_ID}, $opts->{species_id} );
is( $dba_args->[0]->{-MULTISPECIES_DB}, 0 );


my $srcopts = { srchost   => $dba->dbc()->host(),
                srcuser   => $dba->dbc()->username(),
                srcpass   => $dba->dbc()->password(),
                srcport   => $dba->dbc()->port(),
                srcdbname => $dba->dbc()->dbname(), };

debug("Checking prefix options");
my $src_dba_args =
  $cli_helper->get_dba_args_for_opts( $srcopts, 0, "src" );

is( scalar(@$src_dba_args),        1 );
is( $src_dba_args->[0]->{-HOST},   $srcopts->{srchost} );
is( $src_dba_args->[0]->{-USER},   $srcopts->{srcuser} );
is( $src_dba_args->[0]->{-PASS},   $srcopts->{srcpass} );
is( $src_dba_args->[0]->{-PORT},   $srcopts->{srcport} );
is( $src_dba_args->[0]->{-DBNAME}, $srcopts->{srcdbname} );
ok( !defined $src_dba_args->[0]->{-SPECIES} );
ok( !defined $src_dba_args->[0]->{-SPECIES_ID} );
is( $src_dba_args->[0]->{-MULTISPECIES_DB}, 0 );

$src_dba_args =
  $cli_helper->get_dba_args_for_opts( $srcopts, 1, "src" );

is( scalar(@$src_dba_args),        1 );
is( $src_dba_args->[0]->{-HOST},   $srcopts->{srchost} );
is( $src_dba_args->[0]->{-USER},   $srcopts->{srcuser} );
is( $src_dba_args->[0]->{-PASS},   $srcopts->{srcpass} );
is( $src_dba_args->[0]->{-PORT},   $srcopts->{srcport} );
is( $src_dba_args->[0]->{-DBNAME}, $srcopts->{srcdbname} );
ok( !defined $src_dba_args->[0]->{-SPECIES} );
ok( !defined $src_dba_args->[0]->{-SPECIES_ID} );
is( $src_dba_args->[0]->{-MULTISPECIES_DB}, 0 );

$multi->restore('core');

done_testing();

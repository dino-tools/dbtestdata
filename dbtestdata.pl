#! perl --
{
  package dbtestdata;
  
  use strict;
  use warnings;
  use data::VariableDataGenerator;
  use sql::VariableSQLGenerator;
  use utf8;
  use DBI;
  use Getopt::Long;
  use IO::Handle;

  ##
  # DBテストデータ作成ツール。
  # 
  # usage:
  #   perl dbtestdata.pl insert|update|delete OPTIONS
  ##
  
  my $PULSE_COMMIT = 10000;
  our %options = (
    'conf' => []
  );

  exit main();

  ##
  # エントリポイント
  ##
  sub main {
    GetOptions(
        \%options,
        "username:s",
        "password",
        "database:s",
        "hostname:s",
        "conf:s@"
    );

    my $mode = $ARGV[0];
    my @confs = @{ $options{'conf'} || [] };
    
    if ($mode !~ m/^(insert|update|delete)$/) {
      die "unknown mode";
    }
    map{ -f($_) || die "conf not found: $_"; }@confs;
    
    my $db = getConnection();
    foreach my $conffile (@confs) {
      my $config = require($conffile);
      my $proc = "main_${mode}";
      
      STDOUT->print("<", $config->{'name'}, ">\n");
      no strict 'refs';
      $proc->($db, $config);
    }
    
    STDOUT->print("\n");
    STDOUT->print("ended.\n");
    
    $db->rollback();
    return 0;
  }

  ##
  # DBIを返す
  ##
  sub getConnection() {
    my $password = undef;
    if ($options{'password'}) {
      while (1) {
        STDERR->print("password: ");
        STDERR->flush();
        $password = STDIN->getline();
        chomp($password);
        $password && last;
      }
    }
    
    my $db = DBI->connect(
      sprintf("dbi:mysql:%s:%s", $options{'database'} || '', $options{'hostname'} || ''),
      $options{'username'},
      $password
    ) || die $DBI::error;
    
    # ここがMySQL5依存(^^;
    $db->do("SET NAMES utf8");
    $db->do("SET SESSION wait_timeout = 1000000");
    
    return $db;
  }

  ##
  # テストデータのINSERTをします
  ##
  sub main_insert {
    my($db, $config) = @_;
    
    $db->{AutoCommit} = 0;
    my $confInsert = $config->{'insert'};
    
    while (my($table, $conf) = each(%$confInsert)) {
      STDOUT->print("INSERT $table\n");
      
      local $| = 1;
      my $count = 0;
      for (my $i=0; $i<$conf->{'count'}; $i++) {
        $db->do(
          INSERT_SQL(
            $table,
            $conf->{'clazz'}
          )
        ) || die $DBI::error;
        
        $count++;
        if (! ($count % $PULSE_COMMIT)) {
          my $bar = $count % ($PULSE_COMMIT*2) ? '|' : '-';
          $db->commit() || die $DBI::error;
          STDOUT->print("\r$bar $count commited.");
        }
      }
      
      $db->commit() || die $DBI::error;
      STDOUT->print("\r+ $count commited.\n");
      
      STDOUT->print("finished.\n");
    }
  }

  ##
  # テストデータのUPDATEをします
  ##
  sub main_update {
    my($db, $config) = @_;
    
    $db->{AutoCommit} = 0;
    my $confUpdate = $config->{'update'};
    
    while (my($table, $conf) = each(%$confUpdate)) {
      STDOUT->print("UPDATE $table\n");
      
      my $sql = sprintf("SELECT %s FROM %s", $conf->{'primary'}, $table);
      my $sth = $db->prepare($sql) || die $DBI::error;
      $sth->execute() || die $DBI::error;
      
      my @primaryKeys;
      while (my $row = $sth->fetchrow_arrayref()) {
        push(@primaryKeys, $row->[0]);
      }
      
      local $| = 1;
      my $count = 0;
      foreach my $id (@primaryKeys) {
        $db->do(
          UPDATE_SQL(
            $table,
            $conf->{'clazz'},
            [ WHERE($conf->{'primary'}, $id) ]
          )
        ) || die $DBI::error;
        
        $count++;
        if (! ($count % $PULSE_COMMIT)) {
          my $bar = $count % ($PULSE_COMMIT*2) ? '|' : '-';
          $db->commit() || die $DBI::error;
          STDOUT->print("\r$bar $count commited.");
        }
      }
      
      $db->commit() || die $DBI::error;
      STDOUT->print("\r+ $count commited.\n");
      
      STDOUT->print("finished.\n");
    }
  }

  ##
  # レコードを全DELETEします
  ##
  sub main_delete {
    my($db, $config) = @_;
    
    $db->{AutoCommit} = 1;
    my $confDelete = $config->{'delete'};
    
    foreach my $t (@$confDelete) {
      STDOUT->print("DELETE $t\n");
      $db->do("DELETE FROM $t") || die $DBI::error;
      STDOUT->print("finished.\n");
    }
  }
  
  1;
}

__END__

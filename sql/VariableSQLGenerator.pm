{
    package sql::VariableSQLGenerator;
    use base Exporter;
    
    use strict;
    use data::VariableDataGenerator;
    use utf8;
    
    ##
    # VariableDataを使って
    # INSERTやUPDATE文を作成します。
    ##
    
    our @EXPORT = qw(INSERT_SQL INSERT_COUNT UPDATE_SQL SQL SQLQUOTE WHERE );
    
    ##
    # INSERT文の生成
    # @return string SQL文
    # @param string table 対象テーブル名
    # @param HASHREF dataClazz データ
    ##
    sub INSERT_SQL {
        my($table, $dataClazz) = @_;
        
        my @cols;
        my @dataValues;
        while (my($n,$v) = each(%$dataClazz)) {
            push(@cols, $n);
            $v = _lbox($v);
            if ($v->{'type'} eq 'SQL') {
                push(@dataValues, $v->{'gen'}->());
            } else {
                push(@dataValues, _sqlquote($v->{'gen'}->()));
            }
        }
        
        my $sql = "";
        $sql .= "INSERT INTO $table(";
        $sql .= join(',', @cols);
        $sql .= ") VALUES(";
        $sql .= join(',', @dataValues);
        $sql .= ")";
        
        return $sql;
    }
    
    ##
    # UPDATE文の生成
    # @return string SQL文
    # @param string table 対象テーブル名
    # @param HASHREF dataClazz データ カラム名をキーとしたVariableDataの連想配列
    # @param ARRAYREF condClazz 対象レコード条件 WHERE()の返却値の配列
    ##
    sub UPDATE_SQL {
        my($table, $dataClazz, $condClazz) = @_;
        $condClazz ||= [];
        
        my @dataValues;
        while (my($n,$v) = each(%$dataClazz)) {
            $v = _lbox($v);
            if ($v->{'type'} eq 'SQL') {
                push(@dataValues, "$n=".$v->{'gen'}->());
            } else {
                push(@dataValues, "$n="._sqlquote($v->{'gen'}->()));
            }
        }
        
        my $condSql = join(' AND ', @$condClazz);
        
        my $sql = "";
        $sql .= "UPDATE $table SET ";
        $sql .= join(',', @dataValues);
        $sql .= " WHERE ";
        if ($condSql) { $sql .= $condSql; }
        
        return $sql;
    }
    
    ##
    # クオートしません
    # 例: SQL('NOW()')
    # @return VariableData
    ##
    sub SQL {
        my($vd) = @_;
        return {
            "type" => 'SQL',
            "gen"  => sub{
                return _lbox($vd)->{'gen'}->();
            }
        };
    }
    
    ##
    # UPDATE_SQLのレコード条件に使います。
    ##
    sub WHERE {
        my($column, $value, $type) = @_;
        $type ||= 'EQUAL';
       
        if ($type eq 'EQUAL') {
            return "($column = "._sqlquote($value).")";
            
        } elsif ($type eq 'NOT_EQUAL') {
            return "($column <> "._sqlquote($value).")";
            
        } elsif ($type eq 'LIKE') {
            return "($column LIKE "._sqlquote($value).")";
            
        } elsif ($type eq 'NOT_LIKE') {
            return "($column NOT LIKE "._sqlquote($value).")";
            
        } else {
            die("WHERE: unknown type $type");
        }
    }
    
    ###########################################################################
    # 内部関数 ################################################################
    ###########################################################################
    
    ##
    # いろんなデータベースに対応できるといいんだけどなあ
    ##
    sub _sqlquote {
        my($value) = @_;
        
        if ($value !~ m/^\d+$/) {
            $value =~ tr/\'/\'\'/;
            $value = "'$value'";
        }
        
        return $value;
    }
    
    ##
    # 文字列をLITERAL()にボクシングします
    # @return VariableData LITERAL
    ##
    sub _lbox {
        my($v) = @_;
        return ref($v) ? $v : LITERAL($v);
    }
    
    1;
}
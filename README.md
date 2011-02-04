# NAME

dbtestdata

# WHAT IS THIS?

**MySQL専用です!!**

データベースにダミーのテストデータを挿入したり、

すでにあるデータをダミー化したり、不要なデータを削除したりできます。

どのようなダミー化を行うかは設定ファイルで定義します。

# INSTALL

dbtestdata/ ディレクトリの内容があれば動作します。

チェックアウトしてご利用下さい。

# DESCRIPTION

**コマンドラインの起動の方法**

    perl \
      dbtestdata.pl \
        insert \
        --username=root \
        --password \
        --database=hogedb \
        --conf=./conf1.pl \
        --conf=./conf2.pl

**コマンドライン引数の説明**

* insert|update|delete - データの挿入 or ダミー化 or 不要データの削除 のいずれかの動作モードを選択します。
  insert or updateでは設定ファイルのupdatesの内容を参照します。deleteでは設定ファイルのdeletesの内容を参照します。
* --username - データベースのユーザ名。
* --password - データベースにパスワードがかかっているならこれを指定してください。
* --database - ターゲットのデータベース名。
* --conf=FILE名 - 設定ファイル名。複数個指定できます。

**設定ファイルについて**

通常のperlスクリプトです。以下のようなデータ構造をreturnしてください。必ずutf8で記述すること。

    {
      name => この定義の名前,
      updates => {
        テーブル名1 => {
          primary => 主キーカラム名,
          count => テストデータ作成時の作成レコード数,
          pluse_commit => 10000件ごとにコミットするかどうか（データ量が巨大な場合高速です）,
          clazz => {
            カラム名1 => データ生成関数,
            カラム名2 => データ生成関数
          }
        },
        テーブル名2 => {
        },
        テーブル名3 => {
        },
      },
      deletes => [
        レコードを全削除したいテーブル名1,
        レコードを全削除したいテーブル名2
      ]
    }

**データ生成関数**

これらが使えます。

    RANDOM_LITERAL
    RANDOM_INTEGER
    RANDOM_DOUBLE
    RANDOM_ALPHA
    RANDOM_JA_KATAKANA
    RANDOM_JA_HIRAGANA
    RANDOM_JA_PREF
    RANDOM_JA_NAME_KAN
    RANDOM_JA_FIRSTNAME_KAN
    RANDOM_JA_FAMILYNAME_KAN
    RANDOM_JA_ZIPCODE
    RANDOM_JA_TEL
    RANDOM_DATETIME
    RANDOM_EMAIL
    PERL
    LITERAL
    COUNTER
    CONCAT
    SPRINTF
    FOLD
    SQL

詳細については以下のファイルの関数コメントを参照して下さい。

* data/VariableDataGenerator.pm
* sql/VariableSQLGenerator.pm

# EXAMPLE

    package example1;
    
    use strict;
    use warnings;
    use data::VariableDataGenerator;
    use sql::VariableSQLGenerator;
    use utf8;
    
    return {
      name => __PACKAGE__,
      updates => {
        t_user => {
          primary => "id",
          count => 50000,
          pulse_commit => 1,
          clazz => {
            age                       => RANDOM_INTEGER(70, 15),
            card_types_id             => RANDOM_LITERAL(0, 5),
            card_id                   => RANDOM_INTEGER(180, 1),
            level                     => RANDOM_INTEGER(99, 1),
            modified                  => RANDOM_DATETIME("2011-01-01", "2011-12-31"),
            created                   => SQL('NOW()')
          }
        },
        t_order => {
          primary => "id",
          count => 10000000,
          pulse_commit => 1,
          clazz => {
            t_user_id                 => RANDOM_INTEGER(50000, 1),
            price                     => RANDOM_INTEGER(100000, 1000),
            item_id                   => RANDOM_INTEGER(180, 1),
            modified                  => RANDOM_DATETIME("2011-01-01", "2011-12-31"),
            created                   => SQL('NOW()')
          }
        }
      },
      deletes => [ qw(
        t_mail_log
        t_credit_card_log
      )]
    };

# CHANGELOG

* 2011/02/03 初版

# AUTHOR

* ryer

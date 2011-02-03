{
    package data::VariableDataGenerator;
    use base Exporter;
    
    use strict;
    use utf8;
    use Time::Local;
    use POSIX;
    
    ##
    # ランダムなデータを生成します。
    #
    # 以下の連想配列データ構造をVariableDataと呼称します。
    # {
    #     gen  => sub{ ... }  値生成ルーチン
    #     type => 'RANDOM_LITERAL',   タイプ（関数名）
    # }
    # 
    # 値生成ルーチンは引数をとりません。
    # 実行するたびに値を生成するルーチンになります。
    # 通常はクロージャとして実装されています。
    # 
    # 値はすべてutf8値として返却されます。
    ##
    
    our @EXPORT = qw(
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
    );
    
    ###########################################################################
    # ランダム生成タイプ ######################################################
    ###########################################################################
    
    ##
    # @return VariableData
    # 
    # RANDOM_LITERAL('男', '女', '不明')
    # => '女'
    ##
    sub RANDOM_LITERAL {
        my(@literal) = @_;
        return {
            "type" => 'RANDOM_LITERAL',
            "gen"  => sub{
                _selectRandomOne(@literal)
            }
        };
    }

    ##
    # @return VariableData
    # 
    # RANDOM_INTEGER(20)
    # => '15'
    # RANDOM_INTEGER(100, 40)
    # => '98'
    ##
    sub RANDOM_INTEGER {
        my($size, $min) = @_;
        
        if (! defined $min) {
            $min = 0;
        }
        
        return {
            "type" => 'RANDOM_INTEGER',
            "gen"  => sub{
                return int rand($size + 1 - $min) + $min;
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_DOUBLE(20)
    # => '15.231'
    # RANDOM_DOUBLE(100, 40)
    # => '98.8861'
    ##
    sub RANDOM_DOUBLE {
        my($size, $min) = @_;
        
        if (! defined $min) {
            $min = 0;
        }
        
        return {
            "type" => 'RANDOM_DOUBLE',
            "gen"  => sub{
                return rand($size + 1 - $min) + $min;
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_ALPHA(20)
    # => 'CAHJkiJGUIuuZaqoUjtg'
    # RANDOM_ALPHA(100, 40)
    # => 'aSoigqTuqWeikdqoUYIQ ... jJHCAHJkiJGUIukygfuE'
    ##
    sub RANDOM_ALPHA {
        my($size, $min) = @_;
        
        if (! defined $min) {
            $min = $size;
        }
        
        my $str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        my $strlen = length($str);
        
        return {
            "type" => 'RANDOM_ALPHA',
            "gen"  => sub{
                
                my $sz = 0;
                if ($size == $min) {
                    $sz = $size;
                } else {
                    $sz = int rand($size + 1 - $min) + $min;
                }
                
                my $value = '';
                while ($sz--) {
                    my $pos = int rand($strlen);
                    $value .= substr($str, $pos, 1);
                }
                return $value;
            }
        };
    }

    ##
    # @return VariableData
    # 
    # RANDOM_JA_KATAKANA(20)
    # => 'パンベソノクルェケアウィアヲヴァォエオイ'
    # RANDOM_JA_KATAKANA(100, 40)
    # => 'ナコソルリパンベソノク ... アイエオヲヴァォエ'
    ##
    sub RANDOM_JA_KATAKANA {
        my($size, $min) = @_;
        
        my $str = 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
        my $strlen = length($str);
        
        return {
            "type" => 'RANDOM_JA_KATAKANA',
            "gen"  => sub{
                
                my $sz = 0;
                if ($size == $min) {
                    $sz = $size;
                } else {
                    $sz = int rand($size + 1 - $min) + $min;
                }
                
                my $value = '';
                while ($sz--) {
                    my $pos = int rand($strlen);
                    $value .= substr($str, $pos, 1);
                }
                return $value;
            }
        };
    }

    ##
    # @return VariableData
    # 
    # RANDOM_JA_HIRAGANA(20)
    # => 'にぱんべそのくるぇけあうぃをぶぁぇえおい'
    # RANDOM_JA_HIRAGANA(100, 40)
    # => 'なうええけちあぺそのり ... ゆあゅとんきげらそ'
    ##
    sub RANDOM_JA_HIRAGANA {
        my($size, $min) = @_;
        
        my $str = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん';
        my $strlen = length($str);
        
        return {
            "type" => 'RANDOM_JA_HIRAGANA',
            "gen"  => sub{
                
                my $sz = 0;
                if ($size == $min) {
                    $sz = $size;
                } else {
                    $sz = int rand($size + 1 - $min) + $min;
                }
                
                my $value = '';
                while ($sz--) {
                    my $pos = int rand($strlen);
                    $value .= substr($str, $pos, 1);
                }
                return $value;
            }
        };
    }

    ##
    # @return VariableData
    # 
    # これと一緒
    # CONCAT(RANDOM_JA_FAMILYNAME_KAN, ' ', RANDOM_JA_FIRSTNAME_KAN)
    #
    # RANDOM_JA_NAME_KAN('-')
    # => "山田-太郎"
    ##
    sub RANDOM_JA_NAME_KAN {
        my($separator) = @_;
        
        if ($separator) {
            $separator = ' ';
        }
        
        my $genFamiry = RANDOM_JA_FAMILYNAME_KAN()->{'gen'};
        my $genFirst = RANDOM_JA_FIRSTNAME_KAN()->{'gen'};
        
        return {
            "type" => 'RANDOM_JA_FAMILYNAME_KAN',
            "gen"  => sub{
                $genFamiry->().$separator.$genFirst->();
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_JA_FAMILYNAME_KAN()
    # => '山田'
    ##
    sub RANDOM_JA_FAMILYNAME_KAN {
        
        return {
            "type" => 'RANDOM_JA_FAMILYNAME_KAN',
            "gen"  => sub{
                _selectRandomOne(
                    '佐藤','鈴木','高橋','田中','渡辺','伊藤','山本','中村','小林','斎藤','加藤','吉田','山田',
                    '佐々木','山口','松本','井上','木村','林','清水','山崎','中島','池田','阿部','橋本','山下',
                    '森','石川','前田','小川','藤田','岡田','後藤','長谷川','石井','村上','近藤','坂本','遠藤',
                    '青木','藤井','西村','福田','太田','三浦','藤原','岡本','松田','中川','中野','原田','小野',
                    '田村','竹内','金子','和田','中山','石田','上田','森田','小島','柴田','原','宮崎','酒井',
                    '工藤','横山','宮本','内田','高木','安藤','島田','谷口','大野','高田','丸山','今井','河野',
                    '藤本','村田','武田','上野','杉山','増田','小山','大塚','平野','菅原','久保','松井','千葉',
                    '岩崎','桜井','木下','野口','松尾','菊地','野村','新井','渡部'
                )
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_JA_FIRSTNAME_KAN()
    # => '太郎'
    ##
    sub RANDOM_JA_FIRSTNAME_KAN {
        
        return {
            "type" => 'RANDOM_JA_FIRSTNAME_KAN',
            "gen"  => sub{
                _selectRandomOne(
                    '陸','大翔','大輝','蓮','翼','悠斗','翔太','海斗','空','優太','陽斗','大樹','大和','拓海',
                    '涼太','颯','颯太','悠人','一輝','歩夢','陽翔','亮太','翔大','颯汰','悠','悠真','悠翔','遥斗',
                    '陽向','颯斗','海翔','輝','虎太郎','光','光希','匠','琉生','龍之介','和真','翔','葵','響',
                    '健太','樹','太陽','大輔','暖','優斗','雄大','陸斗','涼','怜','怜央','瑛太','健太郎','光輝',
                    '巧','航','太一','拓実','琢磨','天翔','優人','勇斗','悠希','陸翔','颯人','雅也','健人','晃大',
                    '仁','蒼空','大河','大雅','大貴','智也','直哉','哲平','隼','柊斗','唯人','悠太','陽太','翔也',
                    '愛斗','伊織','伊吹','啓斗','健斗','春輝','駿太','心','奏','蒼','蒼真','大智','大夢','拓斗',
                    '達也','宙','柊','優','優希','優輝','勇輝','陸人','凌','塁','漣','煌','翔太郎','颯大',
                    '陽菜','美羽','美咲','さくら','愛','葵','七海','真央','優衣','愛美','杏','結菜','優奈','楓',
                    '結愛','美優','彩花','菜々美','遥','彩音','心','優菜','和奏','こころ','ひなた','花菜','芽生',
                    '菜々子','心愛','桃花','美空','凜','杏奈','花音','心優','美結','優花','優月','栞奈','ひより',
                    '愛莉','芽依','彩華','若菜','春菜','桃香','美月','萌','未来','優','遥菜','和花','莉央','莉緒',
                    'はるか','亜美','愛香','愛菜','愛奈','杏菜','琴音','結衣','彩','彩乃','菜月','咲愛','咲希',
                    '日菜','寧々','美緒','舞','萌花','陽香','あおい','愛華','愛梨','愛理','綾音','綾乃','夏希',
                    '花','琴美','結','結奈','彩菜','咲良','詩乃','朱里','春香','心音','心結','心菜','真帆','雪乃',
                    '千尋','奏','奈々','美桜','美里','百花','優芽','友菜','遥香','梨乃','瑠奈','和','茉央','莉子'
                )
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_JA_PREF()
    # => '東京都'
    ##
    sub RANDOM_JA_PREF {
        
        return {
            "type" => 'RANDOM_JA_PREF',
            "gen"  => sub{
                _selectRandomOne(
                    '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県', '茨城県', '栃木県',
                    '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県', '新潟県', '富山県', '石川県', '福井県',
                    '山梨県', '長野県', '岐阜県', '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府',
                    '兵庫県', '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県', '徳島県',
                    '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県',
                    '鹿児島県', '沖縄県'
                )
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_JA_TEL()
    # => '029-581-3882'
    ##
    sub RANDOM_JA_TEL {
        
        return {
            "type" => 'RANDOM_TEL',
            "gen"  => sub{
                return sprintf("0%2d-%03d-%04d",
                    int rand 100,
                    int rand 1000,
                    int rand 10000
                );
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_JA_ZIPCODE()
    # => '224-0053'
    ##
    sub RANDOM_JA_ZIPCODE {
        
        return {
            "type" => 'RANDOM_TEL',
            "gen"  => sub{
                return sprintf("%03d-%04d",
                    int rand 1000,
                    int rand 10000
                );
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # "YYYY-MM-DD" か "YYYY-MM-DD HH:MM:SS" か undef(現在)を渡す
    # デフォルトの返却フォーマットは "%Y-%m-%d %H:%M:%S"
    # 
    # RANDOM_DATETIME("2010-01-05 10:34:25")
    # => '2009-01-01 09:22:34'
    # RANDOM_DATETIME("2010-01-05", "2000-00-10")
    # => '2009-03-11 12:22:45'
    # RANDOM_DATETIME(undef, "2000-00-10", "%Y/%m/%d")
    # => '2006/12/22'
    ##
    sub RANDOM_DATETIME {
        my($to, $from, $dateFormat) = @_;
        
        my $timeTo;
        if (! $to) {
            $timeTo = time();
        } elsif ($to =~ m/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/) {
            $timeTo = timelocal($6, $5, $4, $3, $2-1, $1);
        } elsif ($to =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/) {
            $timeTo = timelocal(59, 59, 23, $3, $2-1, $1);
        } else {
            die("RANDOM_DATETIME: invalid datetime '$to'");
        }
        
        my $timeFrom;
        if (! $from) {
            $timeFrom = time();
        } elsif ($from =~ m/(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/) {
            $timeFrom = timelocal($6, $5, $4, $3, $2-1, $1);
        } elsif ($from =~ m/(\d\d\d\d)-(\d\d)-(\d\d)/) {
            $timeFrom = timelocal(0, 0, 0, $3, $2-1, $1);
        } else {
            die("RANDOM_DATETIME: invalid datetime '$from'");
        }
        
        if (! $dateFormat) {
            $dateFormat = "%Y-%m-%d %H:%M:%S";
        }
        
        return {
            "type" => 'RANDOM_DATETIME',
            "gen"  => sub{
                my $randomIt = int rand($timeTo - $timeFrom);
                POSIX::strftime($dateFormat, localtime($timeFrom + $randomIt));
            }
        };
    }
    
    ##
    # @return VariableData
    # 
    # RANDOM_EMAIL()
    # => 'dyk23i@jhd82kg74.com.test'
    ##
    sub RANDOM_EMAIL {
        
        my $genUser = RANDOM_ALPHA(10, 5)->{'gen'};
        my $genHost = RANDOM_ALPHA(10, 5)->{'gen'};
        my $genDomain = RANDOM_LITERAL('com.test', 'jp.test', 'tv.test', 'org.test', 'net.test')->{'gen'};
        
        return {
            "type" => 'RANDOM_EMAIL',
            "gen"  => sub{
                $genUser->().'@'.$genHost->().'.'.$genDomain->();
            }
        };
    }
    
    ###########################################################################
    # 特殊タイプ ##############################################################
    ###########################################################################

    ##
    # @return VariableData
    # Perlコードを指定
    # 
    # PERL(sub{ rand(99999) });
    # => '89827'
    ##
    sub PERL {
        my($gen) = @_;
        return {
            "type" => 'PERL',
            "gen"  => $gen
        };
    }
    
    ##
    # @return VariableData
    # リテラル
    # 
    # LITERAL('HELLO')
    # => 'HELLO'
    ##
    sub LITERAL {
        my($literal) = @_;
        return {
            "type" => 'LITERAL',
            "gen"  => sub{
                $literal
            }
        };
    }
    
    ##
    # @return VariableData
    # インクリメンタルカウンタ
    # 
    # マジカルインクリメントします。
    # デフォルトは1からはじまります。
    # 
    # COUNTER()
    # => '1' => '1' => '2' ...
    # COUNTER(0)
    # => '0' => '1' => '2' ...
    # COUNTER('A')
    # => 'A' => 'B' => 'C' ...
    ##
    sub COUNTER {
        my($value) = @_;
        
        if (! defined $value) {
            $value = 1;
        }
        
        return {
            "type" => 'COUNTER',
            "gen"  => sub{
                return $value++;
            }
        };
    }
    
    ###########################################################################
    # フォーマッタータイプ ####################################################
    ###########################################################################
    
    ##
    # @return VariableData
    # 文字列連結
    # 
    # CONCAT(
    #     RANDOM_LITERAL('佐藤', '山田'),
    #     LITERAL('/'),
    #     RANDOM_JA_PREF()
    # )
    # => '山田/東京都'
    ##
    sub CONCAT {
        my(@variableData) = @_;
        
        return {
            "type" => 'CONCAT',
            "gen"  => sub{
                my $value = '';
                foreach my $vd (@variableData) {
                    $value .= _lbox($vd)->{'gen'}->();
                }
                return $value;
            }
        };
    }
    
    ##
    # @return VariableData
    # フォーマット
    # 
    # SPRINTF(
    #     "%s/%0.2f",
    #     RANDOM_JA_PREF(),
    #     RANDOM_DOUBLE(99)
    # )
    # => '北海道/27.28'
    ##
    sub SPRINTF {
        my($form, @variableData) = @_;
        
        return {
            "type" => 'SPRINTF',
            "gen"  => sub{
                my @values;
                foreach my $vd (@variableData) {
                    push(@values, _lbox($vd)->{'gen'}->());
                }
                return sprintf($form, @values);
            }
        };
    }
    
    ##
    # @return VariableData
    # 改行をつける
    # 
    # FOLD(20, RANDOM_JA_HIRAGANA(100))
    # => 'なうええけちあぺそのりみぽあいふぁこえう
    #     ねあゅとんきげらそあおえういおごそらいつ
    #     おえういおごそらいつ ... '
    ##
    sub FOLD {
        my($cols, $variableData) = @_;
        
        return {
            "type" => 'FOLD',
            "gen"  => sub{
                my $value = $variableData->{'gen'}->();
                my $cur = $cols;
                while ($cur < length($value)) {
                    substr($value, $cur, 0) = "\n";
                    $cur += $cols + 1;
                }
                return $value;
            }
        };
    }
    
    ###########################################################################
    # 内部関数 ################################################################
    ###########################################################################
    
    ##
    # @return VariableData LITERAL
    #
    # 文字列をLITERAL()にボクシングします
    ##
    sub _lbox {
        my($v) = @_;
        return ref($v) ? $v : LITERAL($v);
    }
    
    ##
    # @return any
    # 
    # 1個選択
    ##
    sub _selectRandomOne {
        my(@items) = @_;
        return $items[int rand scalar @items];
    }
    
    1;
}

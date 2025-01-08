{
  activesupport = {
    dependencies = ["base64" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "logger" "minitest" "securerandom" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "094cv9kxa8hwlsw3c0njkvvayd0wszcz9b6xywv4yajrg83zlmvm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.2.1";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.7";
  };
  base64 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.0";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.8";
  };
  colorator = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f7wvpam948cglrciyqd798gdc6z3cfijciavd0dfixgaypmvy72";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.0";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0chwfdq2a6kbj6xz9l6zrdfnyghnh32si82la1dnpa5h75ir5anl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.4";
  };
  connection_pool = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x32mcpm2cl5492kd6lbjbaf17qsssmpx9kdyr7z1wcif2cwyh0g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.1";
  };
  date = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kz6mc4b9m49iaans6cbx031j9y7ldghpi5fzsdh0n3ixwa8w9mz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.4.1";
  };
  debug = {
    dependencies = ["irb" "reline"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1977s95s9ns6mpbhg68pg6ggnpxxf8wly4244ihrx5vm92kqrqhi";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.10.0";
  };
  drb = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h5kbj9hvg5hb3c7l425zpds0vb42phvln2knab8nmazg2zp5m79";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.1";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a66b0kjk6jx7pai9gc7i27zd0a128gy73nmas98gjz6wjyr4spm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.3";
  };
  eventmachine = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.7";
  };
  faraday = {
    dependencies = ["faraday-net_http" "logger"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00pd34pnfmij5iw1xv73f6d68zng63wyjhmk7dyi010kmb4x5sp6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.11.0";
  };
  faraday-net_http = {
    dependencies = ["net-http"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rg54k4skaz8z7j358p6pdzc9pr84fjq7sdlpicf7s5ig7vb1rlk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.0";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "04hdrlzyri00lgwi4rh8vzy8z8x789p5gc45sk344ib1fr78g730";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "0szml3n6ql6wzl5fq2rcl1w9iksz4zb68p7cbbwkwc5kkp34ikgx";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1621lgx1isrwjj4j27lvlxjfd6v3pnq2ahvhn2y6pp8rb6fya58h";
      target = "x86_64-linux-gnu";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.17.0";
  };
  forwardable-extended = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15zcqfxfvsnprwm8agia85x64vjzr2w0xn9vxfnxzgcv8s699v0v";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.6.0";
  };
  gemoji = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06nw5mfscjmpap7f0bc9f2hj6zd4jy3pk1lhs6llx5my1h138i3k";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.1.0";
  };
  google-protobuf = {
    dependencies = ["bigdecimal" "rake"];
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "00j66q01avpwfmb9h8aa1lh2sn7ga5i0gffz6k3h12c1yj0dwhzy";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "13kz4zlpg0gzicsj7lb5jrv93kqx44jjramnqamq5f1gznbpq971";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1sh8mfdn4n4yzyr2cz5z1lcxszy83ahf7wyf8h2imjshs593kfy7";
      target = "x86_64-linux";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "4.28.2";
  };
  html-pipeline = {
    dependencies = ["activesupport" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "180kjksi0sdlqb0aq0bhal96ifwqm25hzb3w709ij55j51qls7ca";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.14.3";
  };
  "http_parser.rb" = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gj4fmls0mf52dlr928gaq0c0cb0m3aqa9kaa6l0ikl2zbqk42as";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.0";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ffix518y7976qih9k1lgnc17i3v6yrlh0a3mckpxdb4wc2vrp16";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.5";
  };
  io-console = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18pgvl7lfjpichdfh1g50rpz0zpaqrpr52ybn9liv1v9pjn9ysnd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.0";
  };
  irb = {
    dependencies = ["rdoc" "reline"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lh71mn0mszffwvxgiwlp1zyr38kw8d9iqsvbk7fk2j3y7rg2my4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.3";
  };
  jekyll = {
    dependencies = ["addressable" "colorator" "em-websocket" "i18n" "jekyll-sass-converter" "jekyll-watch" "kramdown" "kramdown-parser-gfm" "liquid" "mercenary" "pathutil" "rouge" "safe_yaml" "terminal-table" "webrick"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0638cvpmk3py1w2dxpav6l0c854y6l94b6gyc2aa16i7r897z64a";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.3.3";
  };
  jekyll-feed = {
    dependencies = ["jekyll"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hzwmjrxi57x68i7jx5rxi8qlcbqcbg3di55wywrp53pr0bap6k8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.17.0";
  };
  jekyll-gist = {
    dependencies = ["octokit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03wz9j6yq3552nzf4g71qrdm9pfdgbm68abml9sjjgiaan1n8ns9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.5.0";
  };
  jekyll-sass-converter = {
    dependencies = ["sass-embedded"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00n9v19h0qgjijygfdkdh2gwpmdlz49nw1mqk6fnp43f317ngrz2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.0.0";
  };
  jekyll-seo-tag = {
    dependencies = ["jekyll"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0638mqhqynghnlnaz0xi1kvnv53wkggaq94flfzlxwandn8x2biz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.0";
  };
  jekyll-target-blank = {
    dependencies = ["jekyll" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "150zp7k4g80ycgn6r498rsypzhpczwwpkrv4m10rhax1n6h8p66v";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.2";
  };
  jekyll-watch = {
    dependencies = ["listen"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qd7hy1kl87fl7l0frw5qbn22x7ayfzlv9a5ca1m59g0ym1ysi5w";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.1";
  };
  jemoji = {
    dependencies = ["gemoji" "html-pipeline" "jekyll"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z4yabsvqdb8x1rr60yyzbaf950cyzv984n3jwwvgcmv5j73wk2x";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.13.0";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "048danb0x10mpch6mf88mky35zjn6wk4hpbqq68ssbq58i3fzgfj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.9.1";
  };
  kramdown = {
    dependencies = ["rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ic14hdcqxn821dvzki99zhmcy130yhv5fqfffkcf87asv5mnbmn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.0";
  };
  kramdown-parser-gfm = {
    dependencies = ["kramdown"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a8pb3v951f4x7h968rqfsa19c8arz21zw1vaj42jza22rap8fgv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.0";
  };
  language_server-protocol = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gvb1j8xsqxms9mww01rmdl78zkd72zgxaap56bhv8j45z05hp1x";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.17.0.3";
  };
  liquid = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1czxv2i1gv3k7hxnrgfjb0z8khz74l4pmfwd70c7kr25l2qypksg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.0.4";
  };
  listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rwwsmvq79qwzl6324yc53py02kbrcww35si720490z5w0j497nv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.9.0";
  };
  logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gpg8gzi0xwymw4aaq2iafcbx31i3xzkg3fb30mdxn1d4qhc3dqa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.0";
  };
  mercenary = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f2i827w4lmsizrxixsrv2ssa3gk1b7lmqh8brk8ijmdb551wnmj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.0";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n1akmc6bibkbxkzm1p1wmfb4n9vv397knkgz0ffykb3h1d7kdix";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.25.1";
  };
  net-http = {
    dependencies = ["uri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10n2n9aq00ih8v881af88l1zyrqgs5cl3njdw8argjwbl5ggqvm9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.1";
  };
  nokogiri = {
    dependencies = ["racc"];
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "012jqlpdzywg634dbpbkfmd9kpdfkx3l929sjhjx56f8hkr96lfp";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "03k2845a4i809f8jhjdjxii2bm6xllf658lmqm6fsryyrhbcy5p5";
      target = "x86_64-linux-gnu";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "0785f78pl5yllqv9dc0sdg740n07bi5np7cnr1gljxrm92k3lknr";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    }];
    version = "1.18.1";
  };
  octokit = {
    dependencies = ["faraday" "sawyer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15lvy06h276jryxg19258b2yqaykf0567sp0n16yipywhbp94860";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.25.1";
  };
  open_uri_redirections = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kn05dxh2mry50jwb3ssn9f3cdnzqa7r0xiyrh6zkn5i0sq2krir";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.1";
  };
  pathutil = {
    dependencies = ["forwardable-extended"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12fm93ljw9fbxmv2krki5k5wkvr7560qy8p4spvb9jiiaqv78fz4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.16.2";
  };
  prism = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fi7hvrm2wzbhm21d3w87z5nrqx6z0gwhilvdizcpc9ik21205mi";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.0";
  };
  psych = {
    dependencies = ["date" "stringio"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aq6k7zw1pi022q4ilpfn78l1gka17kn9krqdh45is6khmy4gad4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.2.2";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vqcw3iwby3yc6avs1vb3gfd0vcp2v7q310665dvxfswmcf4xm31";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.0.1";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.1";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "13.2.1";
  };
  rb-fsevent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zmf31rnpm8553lqwibvv3kkx0v7majm1f341xbxc0bk5sbhp423";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.11.2";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vmy8xgahixcz6hzwy4zdcyn2y6d6ri8dqv5xccgzc1r292019x0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.11.1";
  };
  rbs = {
    dependencies = ["logger"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07cwjkx7b3ssy8ccqq1s34sc5snwvgxan2ikmp9y2rz2a9wy6v1b";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.8.1";
  };
  rdoc = {
    dependencies = ["psych"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1niyzaiwz155nhardgxiin44j1wnrsp73pwwl8xxzj9si0hm0rnv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.10.0";
  };
  redcarpet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sg9sbf9pm91l7lac7fs4silabyn0vflxwaa2x3lrzsm0ff8ilca";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.6.0";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lirwlw59apc8m1wjk85y2xidiv0fkxjn6f7p84yqmmyvish6qjp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.6.0";
  };
  rexml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1j9p66pmfgxnzp76ksssyfyqqrg7281dyi3xyknl3wwraaw7a66p";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.9";
  };
  rouge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "072qvvrcqj0yfr3b0j932mlhvn41i38bq37z7z07i3ikagndkqwy";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.3.0";
  };
  ruby-lsp = {
    dependencies = ["language_server-protocol" "prism" "rbs" "sorbet-runtime"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x8wdj97nv77lyvwnh4d11vyg12r9fx2gskyjvrqqiz5qrijnd7z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.23.1";
  };
  safe_yaml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j7qv63p0vqcd838i2iy2f76c3dgwzkiz1d1xkg7n0pbnxj2vb56";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.5";
  };
  sass-embedded = {
    dependencies = ["google-protobuf"];
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "0587x4mj571nkf1dqsgbr8bwhivilc3y5l859k6kxm3jxf9qa1v7";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "09vpcg9xdsjnpwyr9fwvzpld74s4ka437b9y0zni1yg5mrkarzzp";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1p7bapiygx2ll1v70sxph4xl0h49ggamj7r9h1fhwj96w5h9gzj8";
      target = "x86_64-linux-gnu";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.77.8";
  };
  sawyer = {
    dependencies = ["addressable" "faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jks1qjbmqm8f9kvwa81vqj39avaj9wdnzc531xm29a55bb74fps";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.9.2";
  };
  securerandom = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1phv6kh417vkanhssbjr960c0gfqvf8z7d3d9fd2yvd41q64bw4q";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.1";
  };
  sorbet-runtime = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03hc3sdfajjcss2pvjbbklmis8cfqzfplyr1vi1m6h4ygbpwzgw7";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.11734";
  };
  stringio = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cd1kdrf62p2ya3ia4rz49d5012bqinvqjmcgkakknswz0l1hkr0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.2";
  };
  terminal-table = {
    dependencies = ["unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14dfmfjppmng5hwj7c5ka6qdapawm3h6k9lhn8zj001ybypvclgr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.0.2";
  };
  typeprof = {
    dependencies = ["rbs"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x8f0dhsggbxmfab2z422azzhfcrb81swzbsrgkxhl1hn3d75zrj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.30.1";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.6";
  };
  unicode-display_width = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d0azx233nags5jx3fqyr23qa2rhgzbhv8pxp46dgbg1mpf82xky";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.5.0";
  };
  uri = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07ndgxyhzd02cg94s6rnfhkb9rwx9z72lzk368sa9j78wc9qnbfz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.13.1";
  };
  webrick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "089gy5494j560b242vi173wnbj2913hwlwnjkpzld58r96ilc5s3";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.2";
  };
}
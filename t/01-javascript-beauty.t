#!perl -T

use strict;
use warnings;
use Test::More;
use JavaScript::Beautifier qw/js_beautify/;

# from http://github.com/einars/js-beautify/tree/master/beautify-tests.js

my $tests_num = 0;

my $opts = {
	indent_size => 4,
	indent_character => ' ',
	space_after_anon_function => 1,
	preserve_newlines => 1,
};

sub test_beautifier {
    my ($input, $expected) = @_;

    $expected ||= $input;
    my $result = js_beautify( $input, $opts );
    
    $tests_num++;
    is($result, $expected, $input);
}
sub test_beautifier1 {
    my ($input, $expected) = @_;

    $expected ||= $input;
    my $result = js_beautify( $input, $opts );
    
    $tests_num++;
    $result .= "\n";
    is($result, $expected, $input);
}

sub bt {
    my ($input, $expected) = @_;
    
    test_beautifier(@_);
    $expected ||= $input;
    
    # test also the returned indentation
    # e.g if input = "asdf();"
    # then test that this remains properly formatted as well:
    # {
    # asdf();
    # indent;
    # }
    
    if ( $opts->{indent_size} == 4 && $input ) {
        my $wrapped_input = "{\n" . $input . "\nindent;}";
        my $wrapped_expectation = $expected;
        $wrapped_expectation =~ s/^(.+)$/    $1/mg;
        $wrapped_expectation = "{\n$wrapped_expectation\n    indent;\n}";
        test_beautifier($wrapped_input, $wrapped_expectation);
    }
}

bt( 'a        =          1', 'a = 1');
bt( 'a=1', 'a = 1');
bt( "a();\n\nb();", "a();\n\nb();");
bt( 'var a = 1 var b = 2', "var a = 1\nvar b = 2");
bt( 'var a=1, b=c[d], e=6;', "var a = 1,\nb = c[d],\ne = 6;");
bt( 'a = " 12345 "');
bt( "a = ' 12345 '");
bt( 'if (a == 1) b = 2;', "if (a == 1) b = 2;");
bt( 'if(1){2}else{3}', "if (1) {\n    2\n} else {\n    3\n}" );
bt( 'if(1||2);', 'if (1 || 2);' );
bt( '(a==1)||(b==2)', '(a == 1) || (b == 2)' );
bt( 'var a = 1 if (2) 3;', "var a = 1\nif (2) 3;" );
bt('a /= 5');
bt('a = 0.5 * 3');
bt('a *= 10.55');
bt('a < .5');
bt('a <= .5');
bt('a<.5', 'a < .5');
bt('a<=.5', 'a <= .5');
bt('a = 0xff;');
bt( 'a=0xff+4', 'a = 0xff + 4' );
bt( 'a = [1, 2, 3, 4]');
bt( 'F*(g/=f)*g+b', 'F * (g /= f) * g + b' );
bt( 'a.b({c:d})', "a.b({\n    c: d\n})" );
bt( "a.b\n(\n{\nc:\nd\n}\n)", "a.b({\n    c: d\n})" );
bt( 'a=!b', 'a = !b' );
bt( 'a?b:c', 'a ? b : c' );
bt( 'a?1:2', 'a ? 1 : 2' );
bt( 'a?(b):c', 'a ? (b) : c' );
bt( 'x={a:1,b:w=="foo"?x:y,c:z}', "x = {\n    a: 1,\n    b: w == \"foo\" ? x : y,\n    c: z\n}");
bt( 'x=a?b?c?d:e:f:g;', 'x = a ? b ? c ? d : e : f : g;' );
bt( 'x=a?b?c?d:{e1:1,e2:2}:f:g;', "x = a ? b ? c ? d : {\n    e1: 1,\n    e2: 2\n} : f : g;");
bt( 'function void(void) {}' );
bt( 'if(!a)foo();', 'if (!a) foo();' );
bt( 'a=~a', 'a = ~a' );
bt( 'a;/*comment*/b;', "a;\n/*comment*/\nb;" );
bt( 'if(a)break;', "if (a) break;" );
bt( 'if(a){break}', "if (a) {\n    break\n}" );
bt( 'if((a))foo();', 'if ((a)) foo();' );
bt( 'for(var i=0;;)', 'for (var i = 0;;)' );
bt( 'a++;', 'a++;' );
bt( 'for(;;i++)', 'for (;; i++)' );
bt( 'for(;;++i)', 'for (;; ++i)' );
bt( 'return(1)', 'return (1)' );
bt( 'try{a();}catch(b){c();}finally{d();}', "try {\n    a();\n} catch(b) {\n    c();\n} finally {\n    d();\n}" );
bt('(xx)()'); # magic function call
bt('a[1]()'); # another magic function call
bt( 'if(a){b();}else if(c) foo();', "if (a) {\n    b();\n} else if (c) foo();" );
bt( 'switch(x) {case 0: case 1: a(); break; default: break}', "switch (x) {\ncase 0:\ncase 1:\n    a();\n    break;\ndefault:\n    break\n}" );
bt( 'switch(x){case -1:break;case !y:break;}', "switch (x) {\ncase -1:\n    break;\ncase !y:\n    break;\n}" );
bt( 'a !== b' );
bt( 'if (a) b(); else c();', "if (a) b();\nelse c();" );
bt( "// comment\n(function something() {})"); # typical greasemonkey start
bt( "{\n\n    x();\n\n}"); # was: duplicating newlines
bt( 'if (a in b) foo();');
bt( '{a:1, b:2}', "{\n    a: 1,\n    b: 2\n}" );
bt( 'a={1:[-1],2:[+1]}', "a = {\n    1: [-1],\n    2: [+1]\n}" );
bt( 'var l = {\'a\':\'1\', \'b\':\'2\'}', "var l = {\n    'a': '1',\n    'b': '2'\n}" );
bt( 'if (template.user[n] in bk) foo();');
bt( '{{}/z/}', "{\n    {}\n    /z/\n}" );
bt( 'return 45', "return 45" );
bt( 'If[1]', "If[1]" );
bt( 'Then[1]', "Then[1]" );
bt( 'a = 1e10', "a = 1e10" );
bt( 'a = 1.3e10', "a = 1.3e10" );
bt( 'a = 1.3e-10', "a = 1.3e-10" );
bt( 'a = -1.3e-10', "a = -1.3e-10" );
bt( 'a = 1e-10', "a = 1e-10" );
bt( 'a = e - 10', "a = e - 10" );
bt( 'a = 11-10', "a = 11 - 10" );
bt( "a = 1;// comment\n", "a = 1; // comment" );
bt( "a = 1; // comment\n", "a = 1; // comment" );
bt( "a = 1;\n // comment\n", "a = 1;\n// comment" );

bt( "if (a) {\n    do();\n}"); # was: extra space appended
bt( "if\n(a)\nb();", "if (a) b();" ); # test for proper newline removal
 
bt( "if (a) {\n// comment\n}else{\n// comment\n}", "if (a) {\n    // comment\n} else {\n    // comment\n}" ); # if/else statement with empty body
bt( "if (a) {\n// comment\n// comment\n}", "if (a) {\n    // comment\n    // comment\n}" ); # multiple comments indentation
bt( "if (a) b() else c();", "if (a) b()\nelse c();" );
bt( "if (a) b() else if c() d();", "if (a) b()\nelse if c() d();" );

bt("{}");
bt("{\n\n}");
bt("do { a(); } while ( 1 );", "do {\n    a();\n} while (1);");
bt("do {} while (1);");
bt("do {\n} while (1);", "do {} while (1);");
bt("do {\n\n} while (1);");
bt("var a = x(a, b, c)");
bt( "delete x if (a) b();", "delete x\nif (a) b();" );
bt( "delete x[x] if (a) b();", "delete x[x]\nif (a) b();" );
bt( "for(var a=1,b=2)", "for (var a = 1, b = 2)" );
bt( "for(var a=1,b=2,c=3)", "for (var a = 1, b = 2, c = 3)" );
bt( "for(var a=1,b=2,c=3;d<3;d++)", "for (var a = 1, b = 2, c = 3; d < 3; d++)" );
bt( "function x(){(a||b).c()}", "function x() {\n    (a || b).c()\n}" );
bt( "function x(){return - 1}", "function x() {\n    return -1\n}" );
bt( "function x(){return ! a}", "function x() {\n    return !a\n}" );

bt("a = 'a'\nb = 'b'");
bt("a = /reg/exp");
bt("a = /reg/");
bt('/abc/.test()');
bt('/abc/i.test()');
bt( "{/abc/i.test()}", "{\n    /abc/i.test()\n}" );

bt( "{x=#1=[]}", "{\n    x = #1=[]\n}");
bt( "{a:#1={}}", "{\n    a: #1={}\n}");
bt( "{a:#1#}", "{\n    a: #1#\n}" );
test_beautifier( "{a:#1", "{\n    a: #1" ); # incomplete
test_beautifier( "{a:#", "{\n    a: #" ); # incomplete

test_beautifier( "<!--\nvoid();\n// -->", "<!--\nvoid();\n// -->");

test_beautifier( "a=/regexp", "a = /regexp" ); # incomplete regexp

bt( "{a:#1=[],b:#1#,c:#999999#}", "{\n    a: #1=[],\n    b: #1#,\n    c: #999999#\n}" );

bt("a = 1e+2");
bt("a = 1e-2");
bt( "do{x()}while(a>1)", "do {\n    x()\n} while (a > 1)" );

bt( "x(); /reg/exp.match(something)", "x();\n/reg/exp.match(something)" );

bt("something();(", "something();\n(");

bt("function namespace::something()");

test_beautifier( "<!--\nsomething();\n-->", "<!--\nsomething();\n-->" );
test_beautifier( "<!--\nif(i<0){bla();}\n-->", "<!--\nif (i < 0) {\n    bla();\n}\n-->");

test_beautifier( "<!--\nsomething();\n-->\n<!--\nsomething();\n-->", "<!--\nsomething();\n-->\n<!--\nsomething();\n-->");
test_beautifier( "<!--\nif(i<0){bla();}\n-->\n<!--\nif(i<0){bla();}\n-->", "<!--\nif (i < 0) {\n    bla();\n}\n-->\n<!--\nif (i < 0) {\n    bla();\n}\n-->");

bt( '{foo();--bar;}', "{\n    foo();\n    --bar;\n}");
bt( '{foo();++bar;}', "{\n    foo();\n    ++bar;\n}");
bt( '{--bar;}', "{\n    --bar;\n}");
bt( '{++bar;}', "{\n    ++bar;\n}");

# regexps
bt( 'a(/abc\\/\\/def/);b()', "a(/abc\\/\\/def/);\nb()" );
bt( 'a(/a[b\\[\\]c]d/);b()', "a(/a[b\\[\\]c]d/);\nb()" );
test_beautifier('a(/a[b\\[', "a(/a[b\\["); # incomplete char class
# allow unescaped / in char classes
bt( 'a(/[a/b]/);b()', "a(/[a/b]/);\nb()" );

bt( 'a=[[1,2],[4,5],[7,8]]', "a = [\n    [1, 2],\n    [4, 5],\n    [7, 8]]" );
bt( 'a=[a[1],b[4],c[d[7]]]', "a = [a[1], b[4], c[d[7]]]" );
bt( '[1,2,[3,4,[5,6],7],8]', "[1, 2, [3, 4, [5, 6], 7], 8]" );
    
bt( '[[["1","2"],["3","4"]],[["5","6","7"],["8","9","0"]],[["1","2","3"],["4","5","6","7"],["8","9","0"]]]',
      qq~[\n    [\n        ["1", "2"],\n        ["3", "4"]],\n    [\n        ["5", "6", "7"],\n        ["8", "9", "0"]],\n    [\n        ["1", "2", "3"],\n        ["4", "5", "6", "7"],\n        ["8", "9", "0"]]]~ );
    
bt( '{[x()[0]];indent;}', "{\n    [x()[0]];\n    indent;\n}" );

$opts->{space_after_anon_function} = 1;

bt( "// comment 1\n(function()", "// comment 1\n(function ()"); # typical greasemonkey start
bt( "var a1, b1, c1, d1 = 0, c = function() {}, d = '';", "var a1, b1, c1, d1 = 0,\nc = function () {},\nd = '';");
bt( 'var o1=$.extend(a,function(){alert(x);}', "var o1 = \$.extend(a, function () {\n    alert(x);\n}");
bt( 'var o1=$.extend(a);function(){alert(x);}', "var o1 = \$.extend(a);\nfunction () {\n    alert(x);\n}" );

$opts->{space_after_anon_function} = 0;

bt( "// comment 2\n(function()", "// comment 2\n(function()"); # typical greasemonkey start
bt( "var a2, b2, c2, d2 = 0, c = function() {}, d = '';", "var a2, b2, c2, d2 = 0,\nc = function() {},\nd = '';");
bt( 'var o2=$.extend(a,function(){alert(x);}', "var o2 = \$.extend(a, function() {\n    alert(x);\n}");
bt( 'var o2=$.extend(a);function(){alert(x);}', "var o2 = \$.extend(a);\nfunction() {\n    alert(x);\n}");
bt( '{[y[a]];keep_indent;}', "{\n    [y[a]];\n    keep_indent;\n}");
bt( 'if (x) {y} else { if (x) {y}}', "if (x) {\n    y\n} else {\n    if (x) {\n        y\n    }\n}" );

$opts->{indent_size} = 1;
$opts->{indent_char} = ' ';

bt( '{ one_char() }', "{\n one_char()\n}" );

$opts->{indent_size} = 4;
$opts->{indent_char} = ' ';

bt( '{ one_char() }', "{\n    one_char()\n}" );

$opts->{indent_size} = 1;
$opts->{indent_char} = "\t";

# FIXME
#bt( '{ one_char() }', "{\n\tone_char()\n}" );

$opts->{preserve_newlines} = 0;
bt( "var\na=dont_preserve_newlines", "var a = dont_preserve_newlines" );

$opts->{preserve_newlines} = 1;
bt( "var\na=do_preserve_newlines", "var\na = do_preserve_newlines"  );

my $xxinput = <<'EOF';
x=2;eval(function(p,a,c,k,e,d){e=function(c){return c.toString(36)};if(!''.replace(/^/,String)){while(c--){d[c.toString(a)]=k[c]||c.toString(a)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('$(5).4(3(){$(\'.1\').0(2);$(\'.6\').0(d);$(\'.7\').0(b);$(\'.a\').0(8);$(\'.9\').0(c)});',14,14,'html|r5e57|8080|function|ready|document|r1655|rc15b|8888|r39b0|r6ae9|3128|65309|80'.split('|'),0,{}))c=abx;
EOF

my $xxexpected = <<'EOF';
x = 2;
$(document).ready(function() {
 $(\'.r5e57\').html(8080);$(\'.r1655\').html(80);$(\'.rc15b\').html(3128);$(\'.r6ae9\').html(8888);$(\'.r39b0\').html(65309)});c=abx;
EOF

test_beautifier1($xxinput,$xxexpected);

$xxinput = '';
$xxexpected = '';

$xxinput = <<'EOF';
eval(function(p,a,c,k,e,d){e=function(c){return c.toString(36)};if(!''.replace(/^/,String)){while(c--){d[c.toString(a)]=k[c]||c.toString(a)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('2 0="4 3!";2 1=0.5(/b/6);a.9("8").7=1;',12,12,'str|n|var|W3Schools|Visit|search|i|innerHTML|demo|getElementById|document|w3Schools'.split('|'),0,{}))
EOF

$xxexpected = <<'EOF';
var str = "Visit W3Schools!";
var n = str.search(/w3Schools/i);
document.getElementById("demo").innerHTML = n;
EOF

test_beautifier1($xxinput,$xxexpected);

done_testing( $tests_num );

1;


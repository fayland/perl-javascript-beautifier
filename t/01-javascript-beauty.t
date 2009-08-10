#!perl -T

use Test::More;

use JavaScript::Beautifier qw/js_beautify/;

my $opts = {
	indent_size => 4,
	indent_character => ' ',
	space_after_anon_function => 1,
};

# from http://github.com/einars/js-beautify/tree/master/beautify-tests.js
my @tests = (
	[ 'a        =          1', 'a = 1' ],
	[ 'a=1', 'a = 1' ],
	[ "a();\n\nb();", "a();\n\nb();"],
	[ 'var a = 1 var b = 2', "var a = 1\nvar b = 2" ],
	[ 'if (a == 1) b = 2', "if (a == 1) b = 2" ],
	[ 'if(1){2}else{3}', "if (1) {\n    2\n} else {\n    3\n}" ],
	[ 'if(1||2)', 'if (1 || 2)' ],
	[ '(a==1)||(b==2)', '(a == 1) || (b == 2)' ],
	[ 'var a = 1 if (2) 3', "var a = 1\nif (2) 3" ],
	[ 'a=0xff+4', 'a = 0xff + 4' ],
	[ 'F*(g/=f)*g+b', 'F * (g /= f) * g + b' ],
    [ 'a.b({c:d})', "a.b({\n    c: d\n})" ],
    [ "a.b\n(\n{\nc:\nd\n}\n)", "a.b({\n    c: d\n})" ],
    [ 'a=!b', 'a = !b' ],
    [ 'a?b:c', 'a ? b : c' ],
    [ 'a?1:2', 'a ? 1 : 2' ],
    [ 'a?(b):c', 'a ? (b) : c' ],
    [ 'x={a:1,b:w=="foo"?x:y,c:z}', "x = {\n    a: 1,\n    b: w == \"foo\" ? x : y,\n    c: z\n}"],
    [ 'x=a?b?c?d:e:f:g;', 'x = a ? b ? c ? d : e : f : g;' ],
    [ 'x=a?b?c?d:{e1:1,e2:2}:f:g;', "x = a ? b ? c ? d : {\n    e1: 1,\n    e2: 2\n} : f : g;"],
    [ 'if(!a)', 'if (!a)' ],
    [ 'a=~a', 'a = ~a' ],
    [ 'a;/*comment*/b;', "a;\n/*comment*/\nb;" ],
    [ 'if(a)break', "if (a) break" ],
    [ 'if(a){break}', "if (a) {\n    break\n}" ],
    [ 'if((a))', 'if ((a))' ],
    [ 'for(var i=0;;)', 'for (var i = 0;;)' ],
    [ 'a++;', 'a++;' ],
    [ 'for(;;i++)', 'for (;; i++)' ],
    [ 'for(;;++i)', 'for (;; ++i)' ],
    [ 'return(1)', 'return (1)' ],
	[ 'try{a();}catch(b){c();}finally{d();}', "try {\n    a();\n} catch(b) {\n    c();\n} finally {\n    d();\n}" ],
    [ 'if(a){b();}else if(', "if (a) {\n    b();\n} else if (" ],
    [ 'switch(x) {case 0: case 1: a(); break; default: break}', "switch (x) {\ncase 0:\ncase 1:\n    a();\n    break;\ndefault:\n    break\n}" ],
    [ 'switch(x){case -1:break;case !y:break;}', "switch (x) {\ncase -1:\n    break;\ncase !y:\n    break;\n}" ],
    [ 'if (a) b(); else c();', "if (a) b();\nelse c();" ],
    [ '{a:1, b:2}', "{\n    a: 1,\n    b: 2\n}" ],
    [ 'a={1:[-1],2:[+1]}', "a = {\n    1: [-1],\n    2: [+1]\n}" ],
    [ 'var l = {\'a\':\'1\', \'b\':\'2\'}', "var l = {\n    'a': '1',\n    'b': '2'\n}" ],
    [ '{{}/z/}', "{\n    {}\n    /z/\n}" ],
    [ 'return 45', "return 45" ],
    [ 'If[1]', "If[1]" ],
    [ 'Then[1]', "Then[1]" ],
    [ 'a = 1e10', "a = 1e10" ],
    [ 'a = 1.3e10', "a = 1.3e10" ],
    [ 'a = 1.3e-10', "a = 1.3e-10" ],
    [ 'a = -1.3e-10', "a = -1.3e-10" ],
    [ 'a = 1e-10', "a = 1e-10" ],
    [ 'a = e - 10', "a = e - 10" ],
    [ 'a = 11-10', "a = 11 - 10" ],
    [ "a = 1;// comment\n", "a = 1; // comment" ],
    [ "a = 1; // comment\n", "a = 1; // comment" ],
    [ "a = 1;\n // comment\n", "a = 1;\n// comment" ],
 
    [ "if\n(a)\nb()", "if (a) b()" ], # test for proper newline removal
 
    [ "if (a) {\n// comment\n}else{\n// comment\n}", "if (a) {\n    // comment\n} else {\n    // comment\n}" ], # if/else statement with empty body
    [ "if (a) {\n// comment\n// comment\n}", "if (a) {\n    // comment\n    // comment\n}" ], # multiple comments indentation
    [ "if (a) b() else c()", "if (a) b()\nelse c()" ],
    [ "if (a) b() else if c() d()", "if (a) b()\nelse if c() d()" ],
 
    [ "do { a(); } while ( 1 );", "do {\n    a();\n} while (1);" ],
    [ "do {\n} while ( 1 );", "do {} while (1);" ],
    [ "delete x if (a) b();", "delete x\nif (a) b();" ],
    [ "delete x[x] if (a) b();", "delete x[x]\nif (a) b();" ],
    [ "for(var a=1,b=2)", "for (var a = 1, b = 2)" ],
    [ "for(var a=1,b=2,c=3)", "for (var a = 1, b = 2, c = 3)" ],
    [ "for(var a=1,b=2,c=3;d<3;d++)", "for (var a = 1, b = 2, c = 3; d < 3; d++)" ],
    [ "function x(){(a||b).c()}", "function x() {\n    (a || b).c()\n}" ],
    [ "function x(){return - 1}", "function x() {\n    return -1\n}" ],
    [ "function x(){return ! a}", "function x() {\n    return !a\n}" ],
    
    [ "{/abc/i.test()}", "{\n    /abc/i.test()\n}" ],
    [ "{x=#1=[]}", "{\n    x = #1=[]\n}"],
    [ "{a:#1={}}", "{\n    a: #1={}\n}"],
    [ "{a:#1#}", "{\n    a: #1#\n}" ],
    [ "{a:#1", "{\n    a: #1" ], # incomplete
    [ "{a:#", "{\n    a: #" ], # incomplete

    ["<!--\nvoid();\n// -->", "<!--\nvoid();\n// -->"],

    [ "a=/regexp", "a = /regexp" ], # incomplete regexp
    [ "{a:#1=[],b:#1#,c:#999999#}", "{\n    a: #1=[],\n    b: #1#,\n    c: #999999#\n}" ],
    
    [ "do{x()}while(a>1)", "do {\n    x()\n} while (a > 1)" ],
    [ "x(); /reg/exp.match(something)", "x();\n/reg/exp.match(something)" ],

    ["<!--\nsomething();\n-->", "<!--\nsomething();\n-->" ],
    ["<!--\nif(i<0){bla();}\n-->", "<!--\nif (i < 0) {\n    bla();\n}\n-->"],
    ["<!--\nsomething();\n-->\n<!--\nsomething();\n-->", "<!--\nsomething();\n-->\n<!--\nsomething();\n-->"],
    ["<!--\nif(i<0){bla();}\n-->\n<!--\nif(i<0){bla();}\n-->", "<!--\nif (i < 0) {\n    bla();\n}\n-->\n<!--\nif (i < 0) {\n    bla();\n}\n-->"],

    ['{foo();--bar;}', "{\n    foo();\n    --bar;\n}"],
    ['{foo();++bar;}', "{\n    foo();\n    ++bar;\n}"],
    ['{--bar;}', "{\n    --bar;\n}"],
    ['{++bar;}', "{\n    ++bar;\n}"],

    # regexps
    [ 'a(/abc\\/\\/def/);b()', "a(/abc\\/\\/def/);\nb()" ],
    [ 'a(/a[b\\[\\]c]d/);b()', "a(/a[b\\[\\]c]d/);\nb()" ],
    [ 'a(/a[b\\[', "a(/a[b\\[" ], # incomplete char class
    # allow unescaped / in char classes
    [ 'a(/[a/b]/);b()', "a(/[a/b]/);\nb()" ],
 );

plan tests => scalar @tests + 12;

foreach my $t (@tests) {
	my $run_js = js_beautify($t->[0], $opts );
	is $run_js, $t->[1], $t->[0];
}

# test space_after_anon_function
my @test_space_after_anon_function_true = (
    ["// comment 1\n(function()", "// comment 1\n(function ()"], # typical greasemonkey start
    ["var a1, b1, c1, d1 = 0, c = function() {}, d = '';", "var a1, b1, c1, d1 = 0,\nc = function () {},\nd = '';"],
    ['var o1=$.extend(a,function(){alert(x);}', "var o1 = \$.extend(a, function () {\n    alert(x);\n}"],
    ['var o1=$.extend(a);function(){alert(x);}', "var o1 = \$.extend(a);\nfunction () {\n    alert(x);\n}"]
);
foreach my $t (@test_space_after_anon_function_true) {
	my $run_js = js_beautify($t->[0], { %$opts, space_after_anon_function => 1 } );
	is $run_js, $t->[1], $t->[0];
}
my @test_space_after_anon_function_false = (
    ["// comment 2\n(function()", "// comment 2\n(function()"], # typical greasemonkey start
    ["var a2, b2, c2, d2 = 0, c = function() {}, d = '';", "var a2, b2, c2, d2 = 0,\nc = function() {},\nd = '';"],
    ['var o2=$.extend(a,function(){alert(x);}', "var o2 = \$.extend(a, function() {\n    alert(x);\n}"],
    ['var o2=$.extend(a);function(){alert(x);}', "var o2 = \$.extend(a);\nfunction() {\n    alert(x);\n}"],
);
foreach my $t (@test_space_after_anon_function_false) {
	my $run_js = js_beautify($t->[0], { %$opts, space_after_anon_function => 0 } );
	is $run_js, $t->[1], $t->[0];
}

# test indent
my $in = '{ one_char() }';
my $out = "{\n one_char()\n}";
my $js = js_beautify( $in, { indent_size => 1, indent_char => ' ' } );
is($out, $js);

$in = '{ one_char() }';
$out = "{\n    one_char()\n}";
$js = js_beautify( $in, { indent_size => 4, indent_char => ' ' } );
is($out, $js);

# test preserve_newlines
$in = "var\na=dont_preserve_newlines";
$out = "var a = dont_preserve_newlines";
$js = js_beautify( $in, { preserve_newlines => 0 } );
is($out, $js);

$in = "var\na=do_preserve_newlines";
$out = "var\na = do_preserve_newlines";
$js = js_beautify( $in, { preserve_newlines => 1 } );
is($out, $js);

1;
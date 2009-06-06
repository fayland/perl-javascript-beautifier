#!perl -T

use Test::More;

use JavaScript::Beautifier qw/js_beautify/;

my $opts = {
	indent_size => 4,
	indent_character => ' ',
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
    [ 'a?b:c', 'a ? b: c' ], # 'a ? b : c' would need too make parser more complex to differentiate between ternary op and object assignment
    [ 'a?1:2', 'a ? 1 : 2' ], # 'a ? b : c' would need too make parser more complex to differentiate between ternary op and object assignment
    [ 'a?(b):c', 'a ? (b) : c' ], # this works, though
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
    [ 'if (a) b(); else c();', "if (a) b();\nelse c();" ],
    [ '{a:1, b:2}', "{\n    a: 1,\n    b: 2\n}" ],
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
    [ "var a, b, c, d = 0, c = function() {}, d = '';", "var a, b, c, d = 0,\nc = function() {},\nd = '';" ],
    [ "delete x if (a) b();", "delete x\nif (a) b();" ],
    [ "delete x[x] if (a) b();", "delete x[x]\nif (a) b();" ],
    [ "do{x()}while(a>1)", "do {\n    x()\n} while (a > 1)" ],
    [ "x(); /reg/exp.match(something)", "x();\n/reg/exp.match(something)" ],
    
    [ "{/abc/i.test()}", "{\n    /abc/i.test()\n}" ],
    [ "{x=#1=[]}", "{\n    x = #1=[]\n}"],
    [ "{a:#1={}}", "{\n    a: #1={}\n}"],
    [ "{a:#1#}", "{\n    a: #1#\n}" ],
    [ "{a:#1", "{\n    a: #1" ], # incomplete
    [ "{a:#", "{\n    a: #" ], # incomplete

    ["<!--\nvoid();\n// -->", "<!--\nvoid();\n// -->"],

    [ "a=/regexp", "a = /regexp" ], # incomplete regexp
    [ "{a:#1=[],b:#1#,c:#999999#}", "{\n    a: #1=[],\n    b: #1#,\n    c: #999999#\n}" ],

    [ 'var o=$.extend(a,function(){alert(x);}', "var o = \$.extend(a, function() {\n    alert(x);\n}" ],
    [ 'var o=$.extend(a);function(){alert(x);}', "var o = \$.extend(a);\nfunction() {\n    alert(x);\n}" ],
 );

plan tests => scalar @tests + 4;

foreach my $t (@tests) {
	my $run_js = js_beautify($t->[0], $opts );
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
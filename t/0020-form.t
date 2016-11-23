use v6;
use Test; 
use lib <lib>;

plan 11;

use-ok 'HTML::Tag::Tags', 'HTML::Tag::Tags can be use-d';
use HTML::Tag::Tags;
use-ok 'HTML::Tag::Macro::Form', 'HTML::Tag::Macro::Form can be use-d';
use HTML::Tag::Macro::Form;

ok my $form = HTML::Tag::Macro::Form.new(:nolabel, :action('/')), 'HTML::Tag::Macro::Form instantated';

my @def = ( { username => { }},
	    { password => { }},
	    { submit   => { type  => 'submit',
			    value => 'Login', }},
	  );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form minimal def';

ok $form = HTML::Tag::Macro::Form.new(:def(@def), :action('/')), 'HTML::Tag::Macro::Form def passed directly in';

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text"><label for="form-password">Password</label><input name="password" id="form-password" type="text"><label for="form-submit">Submit</label><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with labels';

@def = ( { username => { }},
	 { password => { }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1 }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text"><label for="form-password">Password</label><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with labels excluding one';

my %input;
%input<username> = 'mark';

ok $form = HTML::Tag::Macro::Form.new(:nolabel, :input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate';

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text" value="mark"><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with value test';

@def = ( { username => { }},
	 { password => { type => 'password' }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1 }},
       );

%input<username> = 'mark';
%input<password> = 'supersecret';

ok $form = HTML::Tag::Macro::Form.new(:input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate for pw test';

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text" value="mark"><label for="form-password">Password</label><input name="password" id="form-password" type="password"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with value test password types set no values';


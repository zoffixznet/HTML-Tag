use v6;
use HTML::Tag::Tags;

class HTML::Tag::Macro::Form
{
    has @.def is rw;
    has %.input is rw;
    has $.form-name is rw = 'form';
    has $.action is rw;
    has $.id     is rw;

    method render() {
	my @elements;
	for @.def -> $element {
	    my $name   = $element.keys.first;
	    my %def    = $element{$name};
	    my %tagdef = ();
	    %tagdef<name>  = $name;
	    %tagdef<id>    = "{$.form-name}\-$name";
	    %tagdef<class> = %def<class> if %def<class>:exists;
	    %tagdef<type>  = %def<type>  if %def<type>:exists;

	    # Process input variables
	    my $var = %def<var>:exists ?? %def<var> !! $name;
	    if (%def<value>:exists) {
		%tagdef<value> = %def<value>;
	    }
	    elsif (%.input and %.input«$var»:exists) {
		%tagdef<value> = %.input«$var»;
	    }

	    my $tag = HTML::Tag::input.new(|%tagdef);
	    
	    if %def<nolabel>:exists {
		@elements.push: $tag;
	    } else {
		my $label = %def<label>:exists ?? %def<label> !! $name.tc;
		@elements.push: HTML::Tag::label.new(:text($label, $tag));
	    }
	}
	my $form = HTML::Tag::form.new(:name($.form-name),
				       :text(@elements));
	$form.action = $.action if $.action;
	$form.id     = $.id     if $.id;
	$form.render;
    }
}

=begin pod

=head1 NAME HTML::Tag::Macro::Form - Form Generation Stuff

=head1 SYNOPSIS

    =begin code
    use HTML::Tag::Macro::Form;

    my $form = HTML::Tag::Macro::Form.new(:action('/hg/login/auth'),
                                          :input(%.input));
    $form.def = ({username => {}},
                 {password => { type => 'password' }},
                 {submit   => { value => 'Login',
                                type  => 'submit',
                                label => '' }}
                );

    $form.render;
    =end code

=head1 DESCRIPTION

Generates forms based upon a definition variable passed in. This
variable must be an array of hashes.

The array of hashes represents one form element per hash in the
array. Labels are automatically generated for all form elements by
default.

The hash key represents the HTML name of the hash by default, and the
input variable if given, etc. That key's value represents options for
that form element. These options are listed in pseudocode
below. Detailed descriptions follow.

    =begin code
    HTML::Tag::Macro::Form.new(@def,
                               %input,
                               $form-name,
                               $action,
                               $id);

    @def = 
    ( { name => { nolabel => False,
                  label   => 'Name',
                  type    => 'text',
                  id      => '{$form-name}-$name',
                  name    => name,
                  class   => undef,
                  value   => undef,
                  var     => undef,
                }
       },
    );
    =end code

=head1 ATTRIBUTES

=head2 $form-name

Defines the HTML name attribute of the form. Default is "form".

=head2 $action

Defines the action URL for the form element

=head2 $id

Defines the HTML id attribute for the form tag.

=head2 %input

Defines a key/val hash that represents values submitted to the form.

=head2 @def

Defines the array of hashes that define each form element.

=head1 THE @def ATTRIBUTE

    =begin code
    @def = ( { firstname => {} },
             { lastname  => {} },
             { submit    => {} },
           );
    =end code

This definition would create a form with 3 text inputs named by the
keys. However, we would like the C<submit> form element to be an
actual submit button, and we would like it to have no automatic label
generated for it.

    =begin code
    ...
    { submit => {type    => 'submit',
                 nolabel => 1} },
    ...
    =end code

If you pass in the C<%input> hash, form elements will be matched to
automatically assign their value to the form element named the same as
the key in the C<%input> hash.

If you need to get your input from a different C<%input> key than the
same-named one, you can specify the C<var> option for the element with
the C<%input> key you would like to associate with it.

=head1 METHODS

=head2 render()

Returns the rendered form with all its elements and values.
					   
=end pod

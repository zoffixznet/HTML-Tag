use v6;
use HTML::Tag::Tags;

class HTML::Tag::Macro::Form
{
    has $.form-name    is rw = 'form';
    has @.def          is rw;
    has %.input        is rw;
    has $.action       is rw;
    has $.id           is rw;
    has Bool $.nolabel is rw = False;

    method render() {
	my @elements;
	for @.def -> $element {
	    my $name   = $element.keys.first;
	    my %def    = $element{$name};
	    my %tagdef = ();

	    %tagdef<name>  = %def<name>:exists ?? %def<name> !! $name;

	    %tagdef<id>        = "{$.form-name}\-$name";
	    %tagdef<class>     = %def<class> if %def<class>:exists;
	    %tagdef<type>      = (%def<type> if %def<type>:exists) || 'text';
	    %tagdef<required>  = True if %def<required>;
	    %tagdef<autofocus> = True if %def<autofocus>;

	    # Process input variables
	    my $var = %def<var>:exists ?? %def<var> !! %tagdef<name>;
	    if (%def<value>:exists) {
		unless %tagdef<type> eq 'password' {
		    %tagdef<value> = %def<value>;
		}
	    }
	    elsif (%.input and %.input{$var}:exists) {
		unless %tagdef<type> eq 'password' {
		    %tagdef<value> = %.input{$var};
		}
	    }

	    # Generate the tag
	    my $tag = HTML::Tag::input.new(|%tagdef);
	    @elements.push: %def<tag-before> if %def<tag-before>;

	    # See about swallowing and labels
	    my @interim-tag = ();
	    if $.nolabel or %def<nolabel>:exists {
		@interim-tag.push: $tag;
	    } else {
		my $label = %def<label>:exists ?? %def<label> !! %tagdef<name>.tc.subst('_', ' ');
		@interim-tag.push: HTML::Tag::label.new(:for(%tagdef<id>), :text($label)), $tag;
	    }
	    if (%def<swallowed-by>) {
		%def<swallowed-by>.text.push: |@interim-tag;
		@elements.push: %def<swallowed-by>;
	    } else {
		@elements.push: |@interim-tag;
	    }

	    @elements.push: %def<tag-after> if %def<tag-after>;
	}
	
	my $form = HTML::Tag::form.new(:name($.form-name),
				       :text(@elements));
	$form.action = $.action;
	$form.id     = $.id;
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
		  required     => False,
		  autofocus    => False,
		  tag-after    => HTML::Tag::<whatever>,
		  tag-before   => HTML::Tag::<whatever>,
		  swallowed-by => HTML::Tag::<whatever>,
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

=head2 :nolabel

When present disallows the creation of named labels around all
elements. Elements also have per-element label control defined in the
for @def.

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

=head2 Options for each key defined in @def

=item C<name> - name defaults to the I<key name> for the element
defined in @def. Specifying name here overrides this. Also overrides
the default C<var> name looked for in any %input provided.

=item C<class> - specifies the element's HTML class.

=item C<id> - specifies the element's HTML id.

=item C<type> - specifies the text input's type (such as "submit"). If
the type is "password" no value attribute will ever be printed for the
tag.

=item C<nolabel> - if set to anything, renders no label for this element.

=item C<label> - sets the label to the string provided, instead of
using the default label, which is a titlecase version of
C<name>. Underscores are replaced with spaces automatically in the
label.
											       
=item C<value> - manually sets the value for the element. This will
override any value obtained by processing %input.

=item C<var> - the %input key name to use, to assign C<value>
automatically. This defaults to C<name>.

=item C<tag-after> - HTML::Tag to be inserted directly I<after> this
element.

=item C<tag-before> - HTML::Tag to be inserted directly I<before> this
element.

=item C<swallowed-by> - Provide another HTML::Tag that will swallow up
the element (surround it, like a <span></span>). If labels are being
rendered for the element, those also are swallowed. Also, before and
after happen outside of the swallow.

=item C<required> - Marks the tag as required, which modern browsers
will recognize and enforce, but should not be relied upon for input
processing.

=item C<autofocus> - The tag will have the HTML attribute added to it,
to cause the form input field to receive focus on page load (HTML5).

=head1 METHODS

=head2 render()

Returns the rendered form with all its elements and values.
					   
=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head2 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

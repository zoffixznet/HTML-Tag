use v6;
use HTML::Tag;
use HTML::Tag::Tags;

class HTML::Tag::Macro::CSS
{
    has Str $.href is required;

    method render() {
	return "<link rel=\"stylesheet\" type=\"text/css\" href=\"$!href\">";
    }
}

class HTML::Tag::Macro::Table
{
    has @.rows is rw;
    has $.table-opts is rw = {};

    method row(Bool :$header = False,
	       Hash :$td-opts,
	       Hash :$tr-opts = {},
	       *@cols) {
	
	my @col-objects;
	for @cols.kv -> $i, $col {
	    my $opts = $td-opts{$i}:exists ?? $td-opts{$i} !! {}  ;
	    if ($header) { @col-objects.push: HTML::Tag::th.new(:text($col), |$opts) }
	    else         { @col-objects.push: HTML::Tag::td.new(:text($col), |$opts) }
	}
	@!rows.push: HTML::Tag::tr.new(:text(|@col-objects), |$tr-opts);
    }

    method render() {
	HTML::Tag::table.new(:text(|@!rows), |$!table-opts).render;
    }
}
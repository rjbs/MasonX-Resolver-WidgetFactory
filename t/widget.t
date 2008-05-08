use strict;
use warnings;

use MasonX::Resolver::WidgetFactory;
use MasonX::Resolver::Multiplex;
use HTML::Mason::Resolver::File;
use HTML::Mason::Tests;

my $tests = make_tests();
$tests->run;

{ 
  package HTML::Mason::Commands;
  sub _make_interp { $tests->_make_interp(@_) }
}

sub make_tests {
  my $group = HTML::Mason::Tests->tests_class->new(
    name => "widget",
    description => "WidgetFactory resolver tests",
  );

  my $ip = sub {
    return {
      resolver => MasonX::Resolver::Multiplex->new(
        resolvers => [
          MasonX::Resolver::WidgetFactory->new(
            prefix => '/w',
            @_,
          ),
          HTML::Mason::Resolver::File->new,
        ],
      )
    };
  };

  $group->add_test(
    name => 'basic',
    description => 'basic functionality test',
    interp_params => $ip->(),
    component => <<'',
<& /w/input, id => "test" &>

    expect => <<'',
<input id="test" name="test" />

  );

  $group->add_test(
    name => 'missing',
    description => 'request for missing widget',
    interp_params => $ip->(),
    component => <<'',
<& /w/no_such &>,

    expect_error => qr/could not find component for path/,
  );

  $group->add_test(
    name => 'missing',
    description => 'request for missing widget',
    interp_params => $ip->(strict => 1),
    component => <<'',
<& /w/no_such &>,

    expect_error => qr/factory does not provide/,
  );

  return $group;
}

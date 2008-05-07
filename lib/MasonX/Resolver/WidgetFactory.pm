use strict;
use warnings;

package MasonX::Resolver::WidgetFactory;

our $VERSION = '0.001';

use Moose;
BEGIN { extends 'HTML::Mason::Resolver' }

use HTML::Widget::Factory;
use HTML::Mason::Tools qw(paths_eq);
use File::Spec;

sub validation_spec {
  my $self = shift;
  return {
    %{ $self->SUPER::validation_spec || {} },
    prefix  => 1,
    factory => { optional => 1 },
  },
}

has factory => (
  is => 'rw',
  isa => 'HTML::Widget::Factory',
  lazy => 1,
  default => sub { HTML::Widget::Factory->new },
);

has prefix => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

has source_cache => (
  is => 'rw',
  isa => 'HashRef',
  lazy => 1,
  default => sub { {} },
);

sub _matches {
  my ($self, $path) = @_;
  my $prefix = $self->prefix;
  return $path =~ m{^$prefix(?:/([^/]+))?$};
}

sub get_info {
  my ($self, $path, $comp_root_key, $comp_root_path) = @_;

  my ($widget) = $self->_matches($path) or return;
  
  die "factory does not provide '$widget' ($path)"
    unless $self->factory->provides_widget($widget);

  return HTML::Mason::ComponentSource->new(
    friendly_name   => "$widget widget",
    comp_id         => "widget:$path",
    last_modified   => $^T,
    comp_path       => $path,
    comp_class      => 'HTML::Mason::Component',
    source_callback => sub { $self->generate_source($widget) },
  );
}

sub glob_path {
  my ($self, $pattern, $comp_root_path) = @_;
  return; # meaningless
}

sub generate_source {
  my ($self, $widget) = @_;
  return $self->source_cache->{$widget} ||= do {
    # this is terrible, but I can't see a better way to share the factory
    my $factory = $self->factory;
    my $fac_class = ref $factory;
    { no strict 'refs'; ${ $fac_class . '::factory' } = $factory; }
    sprintf '<%% $%s::factory->%s(\%%ARGS) %%>', $fac_class, $widget;
  };
}

# we don't need apache_request_to_comp_path if we're being used with
# Resolver::File and Multiplex

1;
__END__

=head1 NAME

MasonX::Resolver::WidgetFactory - resolve paths to HTML::Widget::Factory plugins

=head1 VERSION

Version 0.001

=head1 SYNOPSIS

    use MasonX::Resolver::WidgetFactory;

    my $res = MasonX::Resolver::WidgetFactory->new(
      factory => My::Widget::Factory->new,
      prefix => '/widget',
    );

    my $interp = HTML::Mason::Interp->new(
      resolver => $res,
      # ... other options ...
    );

=head1 DESCRIPTION

This Resolver exposes the plugins of a L<HTML::Widget::Factory> object as
virtual components under a given prefix.

For example:

  my $res = MasonX::Resolver::WidgetFactory->new(
    prefix => '/widget',
  );

  # elsewhere:
  
  <& /widget/select, name => "myselect", options => \@options &>

The component call to C</widget/select> is translated to C<< $factory->select(...arguments...) >>.

=head2 prefix

The component path root under which to respond.

=head2 factory

The HTML::Widget::Factory object to use.  Defaults to a new
HTML::Widget::Factory object.

=head1 AUTHOR

Hans Dieter Pearcey, C<< <hdp at pobox.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-masonx-resolver-widgetfactory at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MasonX-Resolver-WidgetFactory>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MasonX::Resolver::WidgetFactory


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MasonX-Resolver-WidgetFactory>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MasonX-Resolver-WidgetFactory>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MasonX-Resolver-WidgetFactory>

=item * Search CPAN

L<http://search.cpan.org/dist/MasonX-Resolver-WidgetFactory>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Hans Dieter Pearcey.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

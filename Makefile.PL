use inc::Module::Install;

name     'MasonX-Resolver-WidgetFactory';
all_from 'lib/MasonX/Resolver/WidgetFactory.pm';
author   'Hans Dieter Pearcey <hdp@pobox.com>';

build_requires 'Test::More';
build_requires 'MasonX::Resolver::Multiplex';

requires 'HTML::Mason' => '1.30';
requires 'HTML::Widget::Factory' => '0.067'; # provides_widget
requires 'Moose' => 0;

WriteAll;

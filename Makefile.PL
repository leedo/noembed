use inc::Module::Install;
name 'Noembed';
perl_version '5.008';
author 'Lee Aylward <leedo@cpan.org>';
license 'perl';
all_from 'lib/Noembed.pm';
requires 'Plack' => '0';
requires 'JSON' => 0;
requires 'Text::MicroTemplate' => '0';
requires 'AnyEvent::HTTP' => '0';
requires 'Web::Scraper' => '0';
requires 'Web::oEmbed' => '0';
requires 'Class::Load' => '0';
requires 'Module::Find' => '0';
requires 'List::MoreUtils' => '0';
test_requires 'Test::More' => '0.86';

WriteAll;

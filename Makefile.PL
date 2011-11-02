use inc::Module::Install;

name 'Noembed';
perl_version '5.008';
author 'Lee Aylward <leedo@cpan.org>';
license 'perl';
all_from 'lib/Noembed.pm';

requires 'AnyEvent::Worker';
requires 'IPC::Run';
requires 'Data::GUID';
requires 'Plack';
requires 'JSON';
requires 'File::ShareDir';
requires 'Text::MicroTemplate';
requires 'AnyEvent::HTTP';
requires 'Class::Load';
requires 'Module::Find';
requires 'List::MoreUtils';
requires 'HTML::Entities';
requires 'Web::Scraper';
requires 'File::Which';

test_requires 'Test::More' => '0.86';

no_index directory => "eg";
install_share;
WriteAll;

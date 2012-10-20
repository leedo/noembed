use inc::Module::Install;

name 'Noembed';
perl_version '5.008';
author 'Lee Aylward <leedo@cpan.org>';
license 'perl';
all_from 'lib/Noembed.pm';

requires 'AnyEvent::Worker';
requires 'IPC::Run3';
requires 'Plack';
requires 'JSON';
requires 'JSON::XS';
requires 'Digest::SHA1';
requires 'URI::Amazon::APA';
requires 'XML::Simple';
requires 'Imager';
requires 'Imager::File::PNG';
requires 'Imager::File::GIF';
requires 'Imager::File::JPEG';
requires 'File::ShareDir';
requires 'Text::MicroTemplate';
requires 'AnyEvent::HTTP';
requires 'Try::Tiny';
requires 'Class::Load';
requires 'Module::Find';
requires 'List::MoreUtils';
requires 'HTML::Entities';
requires 'Web::Scraper';
requires 'File::Which';
requires 'Net::SSLeay';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::CrossOrigin';
requires 'Net::OAuth::ProtectedResourceRequest';

requires_external_bin 'pygmentize';

test_requires 'Test::More' => '0.86';

no_index directory => "eg";
install_share;
WriteAll;

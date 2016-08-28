requires "JSON::XS";
requires "Plack";
requires "Starlet";
requires "LWP::UserAgent";
requires "Module::Find";
requires "Class::Load";
requires "Text::MicroTemplate";
requires "HTML::TreeBuilder";
requires "File::Which";
requires "IPC::Run3";
requires "Web::Scraper";
requires "XML::Simple";
requires "URI::Amazon::APA";
requires "Net::OAuth::ProtectedResourceRequest";
requires "Digest::SHA1";
requires "Plack::Middleware::ReverseProxy";
requires "LWP::Protocol::https";
requires "Imager";
requires "Plack::Middleware::ServerStatus::Lite";
requires "Cache::Memcached";

on 'test' => sub {
  requires "Test::Fatal";
  requires "Test::More";
  requires "URI::Escape";
  requires "HTTP::Message::PSGI";
  requires "File::Path";
};

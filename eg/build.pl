#!/usr/bin/env perl

use v5.14;

use Module::Find;
use Class::Load;
use Data::Dump 'pp';

my @modules = Module::Find::findsubmod("Noembed::Provider");
my %providers;
my %names = (
  "oEmbedProvider" => "Existing oEmbed Sites",
  "ImageProvider"  => "Image Sites",
  "Provider"       => "Other",
  "TwitterCardProvider"       => "Other",
);

for my $module (@modules) {
  no strict 'refs';
  Class::Load::load_class($module);
  my $name = &{"$module\::provider_name"}();
  my ($parent) = @{"$module\::ISA"};
  $parent =~ s/.*:://;
  my $type = $names{$parent} || "Other Sites";
  push @{$providers{$type}}, $name;
}

for my $type (keys %providers) {
  say "<h3>$type</h3>";
  say "<ul>";
  say "<li>$_</li>" for sort @{$providers{$type}};
  say "</ul>"; 
}

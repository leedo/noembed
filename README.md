# NAME

Noembed - oembed gateway

# SYNOPSIS

    use Plack::Builder;
    use Noembed;

    builder {
      mount "/oembed" => builder {
        enable JSONP;
        Noembed->new->to_app;
      };
    };

# DESCRIPTION

Noembed is an oEmbed gateway. It lets you fetch information about
external URLs, which you can then use to embed into HTML pages.
Noembed can fetch information about a large list of URLs, and it
is very easy to define new types of URLs.

To add a new set of URLs to Noembed you create a new class that
inherits from [Noembed::Source](http://search.cpan.org/perldoc?Noembed::Source) and override a few methods.

# CUSTOM SOURCES

Use the `sources` option to load a custom list of source classes.
All classes are assumed to be under the Noembed::Source namespace
unless prefixed with `+`.

    # only load YouTube and a custom source
    my $noembed = Noembed->new(
      sources => [qw/ YouTube +My::Custom::Source /]
    );

    builder {
      mount "/oembed" => $noembed->to_app;
    };

# EXAMPLES

To see an example of how to use Noembed from the client side, take
a look at the demo in the eg/ directory. It accepts a URL and
attempts to embed it in the page.

# AUTHOR

Lee Aylward

# CONTRIBUTORS

- Clint Ecker (Path support)
- Ryan Baumann (Spotify support)
- Bryce Kerley (Spelling fixes)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
# NAME

Noembed - extendable oEmbed gateway

# SYNOPSIS

    use Plack::Builder;
    use Noembed;

    my $noembed = Noembed->new;

    builder {

      # an oEmbed endpoint supporting lots of sites
      mount "/embed" => builder {
        enable "JSONP";
        $noembed->to_app;
      };

      # a CSS file with all the styles
      mount "/noembed.css" => $noembed->css_response;

      # a JSON response describing all the supported sites
      # and what URL patterns they match
      mount "/providers" => $noembed->providers_response;
    };

# DESCRIPTION

Noembed is an oEmbed gateway. It allows you to fetch information
about external URLs, which can then be embeded HTML pages. Noembed
supports a large list of sites and makes it easy to add more.

To add a new site to Noembed create a new class that inherits from
[Noembed::Source](http://search.cpan.org/perldoc?Noembed::Source), [Noembed::ImageSource](http://search.cpan.org/perldoc?Noembed::ImageSource), or [Noembed::oEmbedSource](http://search.cpan.org/perldoc?Noembed::oEmbedSource)
and override the required methods.

# EXAMPLES

To see an example of how to use Noembed from the client side, take
a look at the demo in the eg/ directory. It accepts a URL and
attempts to embed it in the page.

# SEE ALSO

[Noembed::Source](http://search.cpan.org/perldoc?Noembed::Source), [Noembed::ImageSource](http://search.cpan.org/perldoc?Noembed::ImageSource), [Noembed::oEmbedSource](http://search.cpan.org/perldoc?Noembed::oEmbedSource),
[Noembed::Util](http://search.cpan.org/perldoc?Noembed::Util), [Web::Scraper](http://search.cpan.org/perldoc?Web::Scraper)

# AUTHOR

Lee Aylward

# CONTRIBUTORS

- Clint Ecker (Path support)
- Ryan Baumann (Spotify support)
- Bryce Kerley (Spelling fixes)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
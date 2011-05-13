# Noembed - oEmbed everything.

<a href="http://www.oembed.com/">oEmbed</a> is nice. Unfortunately, not
everything supports oEmbed. Worse, the sites that <em>do</em> support
it don't provide a consistent interface. Noembed provides a single <a
href="/embed">url</a> to get embeddable content from a large list of
sites, even sites without oEmbed support!

Additionally, Noembed guarantees that all responses will have
<code>html</code>, <code>title</code>, <code>url</code>,  and
<code>provider_name</code> fields. This means fewer special cases dealing
with missing information.

A simple demo is <a href="demo.html">available here</a>.

##Usage

Treat Noembed like a regular oEmbed provider, but use any of the <a href="#supported-sites">supported sites</a>
for the <code>url</code> parameter. Noembed also supports a <code>callback</code>
parameter for JSONP.
    
An example request might look like this:

<pre>http://www.noembed.com/embed?url=http%3A//www.youtube.com/watch%3Fv%3DbDOYN-6gdRE&amp;callback=my_embed_function</pre>

And the response will look like:


<pre>
my_embed_function(
  {
    "width" : 425,
    "author_name" : "schmoyoho",
    "author_url" : "http://www.youtube.com/user/schmoyoho",
    "version" : "1.0",
    "provider_url" : "http://www.youtube.com/",
    "provider_name" : "YouTube",
    "thumbnail_width" : 480,
    "thumbnail_url" : "http://i3.ytimg.com/vi/bDOYN-6gdRE/hqdefault.jpg",
    "height" : 344,
    "thumbnail_height" : 360,
    "html" : "&lt;iframe type='text/html' width='425' height='344' src='http://www.youtube.com/embed/bDOYN-6gdRE' frameborder=0&gt;&lt;/iframe&gt;",
    "url" : "http://www.youtube.com/watch?v=bDOYN-6gdRE",
    "type" : "rich",
    "title" : "Auto-Tune the News #8: dragons. geese. Michael Vick. (ft. T-Pain)"
  }
) 
</pre>

## Supported sites

### Existing oEmbed

 * Flickr
 * Viddler
 * Qik
 * Hulu
 * Vimeo

### Improved oEmbed

 * Flickr - Photo links are put into an <code>&lt;img&gt;</code> tag.
 * GitHub Gist - Includes the full gist instead of only the first 3 lines.
 * YouTube - Uses an <code>&lt;iframe&gt;</code> so HTML5 video works.

### Other
 * Twitter - Renders tweet along with metadata information.
 * Wikipedia - Includes all paragraphs leading up the the TOC. Includes formatting and links.
 * Giant Bomb - Links to videos will return a <code>&lt;video&gt;</code> tag.


## Development

All the source code for Noembed is <a href="http://www.github.com/leedo/noembed">
on github</a>. Patches are accepted to add new services. To
write a new class, inherit from the <code>Noembed::Source</code>
class and define <code>provider_name</code>, <code>matches</code>,
<code>filter</code>, and <code>request_url</code> methods. Take a
look at an <a href="https://github.com/leedo/noembed/blob/master/lib/Noembed/Source/Wikipedia.pm">existing
source</a> for an example.

## Similar sites

<a href="http://oohembed.com/">Oohembed</a> is a very similar service. It even
acts as a gateway to non-oEmbed enabled sites. The main limitation that I encountered
was its lack of guaranteed <code>html</code> field. Also, it is popular so it
regularly goes over its usage limits.

<a href="http://embed.ly/">embed.ly</a>. I have not tried this service, but it
lists support for hundreds of sites. Unfortunatly, you can not add your own providers,
so you are limited to what they support.

&copy; 2012 Lee Aylward


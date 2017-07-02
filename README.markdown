# What is this?

counsel-surfraw allows the user to search a number of search engines
directly from Emacs.

# Prerequisites

I'm assuming that at this point, you'll have installed `ivy`, `counsel`,
and friends.  This package requires `ivy`.

You'll need to install surfraw.  On Debian/Ubuntu, that would mean

```bash
apt-get install surfraw
```

Just realized that right now there's a hard requirement on Emacs 25+
because I'm using seq.el.

# Installation

```elisp
;; Your typical procedure to install/load packages

(require 'counsel-surfraw)

;; Bind counsel-surfraw to a key
(global-set-key (kbd "C-c w") 'counsel-surfraw)
```

This is not on MELPA yet.

# Usage

`counsel-surfraw` will prompt the user to enter their search terms,
then will provide a list of search engines provided by Surfraw.

You may search for the thing at point by pressing <kbd>M-p</kbd>
at the first prompt.

# How to change the browser

By default, emacs should open links in the OS' default browser.

You can change that, or even open links in Emacs' browsers (`eww`,
`w3m`, etc) by changing `browse-url-browser-function`:

```elisp
;; open in Firefox
(setq browse-url-browser-function 'eww-browse-firefox)
```

```elisp
;; open in Chrome
(setq browse-url-browser-function 'eww-browse-chrome)
```

```elisp
;; open in EWW (built into modern versions of Emacs)
(setq browse-url-browser-function 'eww-browse-url)
```

# Surfraw is missing some search engine I want!

Surfraw's default search engines (which it calls "elvi"; singular
"elvis") look like... they came from Julian Assange's bookmarks.
[Wonder why.](https://en.wikipedia.org/wiki/Julian_Assange#Programming)
The point is, there's some stuff that is useful to me in there,
and some that is not.  But you can fix that semi-easily if you
know some shell script.

If you want to make some search engine that is useful to you, you can
copy one of the elvi; they live under `/usr/lib/surfraw` (on my Ubuntu
box).  You will want to copy it to `$XDG_CONFIG_HOME/surfraw/elvi`
(create it if it doesn't exist).  Then change the text/URLs/etc as
needed.

By way of an example, here's a simple elvis I wrote to search
[jisho.org](http://jisho.org):

```bash
#!/bin/sh
# elvis: jisho 		-- Search Japanese dictionary
# Author: J. W. Smith

. surfraw || exit 1

w3_usage_hook () {
    cat <<EOF
Usage: $w3_argv0 [search-string]
Description:
    Surfraw search Japanese dictionary (jisho.org)
EOF
    w3_global_usage
}

w3_config
w3_parse_args "$@"
# w3_args now contains a list of arguments

url="http://jisho.org/"

if [ -n "$w3_args" ]; then
    escaped_args=$(w3_url_of_arg $w3_args)
    url="${url}search/${escaped_args}"
fi

w3_browse_url "$url"
```

There are more elaborate elvi, that take options, etc.
counsel-surfraw does not do any of that, and thus if you're only using
surfraw from counsel-surfraw, you don't need anything more complicated
than the above.

Note that counsel-surfraw is expecting the format of that second line
after `elvis: ` to be something like "nameofelvi -- Search blah blah
description".  surfraw uses that text directly in `surfraw -elvi`,
which counsel-surfraw parses to build the list of search engines.

# Inspiration

[Helm](https://github.com/emacs-helm/helm) has a
[similar command](https://github.com/emacs-helm/helm/blob/master/helm-net.el)
in its main distribution.

# Why not use DuckDuckGo bangs?  Sounds similar, and has more stuff.

If DDG could provide some kind of API endpoint from which I could
query the list of bangs and make it searchable from ivy, it would be a
MUCH more robust option at this point.  (For one, it'd work on Windows
more easily.)  Until then...

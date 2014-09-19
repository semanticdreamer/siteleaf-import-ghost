# Import Ghost blog posts to Siteleaf.

Ruby import script for importing blog post from the [Ghost][Ghost] blogging platform into [Siteleaf][Siteleaf].

The script imports the blog posts from [Ghost][Ghost]'s `*.json` export file for blog settings and data into a configurable Siteleaf site and page.

The script leverages the [Siteleaf Gem][Siteleaf Gem] for accessing the [Siteleaf API][Siteleaf API]. 

## Credits

Based on [sskylar](https://gist.github.com/sskylar)'s [Siteleaf import script](https://gist.github.com/sskylar/5824224).

## Prerequisites

- [Ruby][Ruby] (tested with **v2.1.2**)
- [Bundler][Bundler]

## Setup

Install required `gems` (see `Gemfile`), preferably using [Bundler][Bundler]:

    $ bundle install

## Usage

Rename `config.yml.dist` to `config.yml` and provide your configuration...

The, run on the command line:

    $ ruby importer.rb

... and relax! :-)

## Todo

- Add support for images uploaded to Ghost: parse image file path (`![]()`) from Ghost's `markdown` content, then fetch (download) the file and upload the asset to Siteleaf.

[Siteleaf]: http://siteleaf.com/
[Siteleaf Gem]: https://github.com/siteleaf/siteleaf-gem
[Siteleaf API]: https://github.com/siteleaf/siteleaf-api
[Ghost]: http://ghost.org/
[Ruby]: http://www.ruby-lang.org/
[Bundler]: http://bundler.io/

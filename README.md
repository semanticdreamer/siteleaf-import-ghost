# Import Ghost blog posts to Siteleaf.

Ruby import script for importing blog post from the [Ghost][Ghost] blogging platform into [Siteleaf][Siteleaf].

The script leverages the [Siteleaf Gem][Siteleaf Gem] for accessing the [Siteleaf API][Siteleaf API]. 

## Features

The script will import the blog posts from [Ghost][Ghost]'s `*.json` export file into a configurable (`config.yml`) Siteleaf site and page.

**Fields**

The following blog post fields are imported:

- `title`
- `status` (`published -> visible, draft -> draft`)
- `markdown` content/ body
- `published_at` date
- `tags`

**Asset Handling**

The relative image asset's file path (`![](/contents/images/.../image.png)`) from Ghost's `markdown` content are parsed and udpated to match Siteleaf's `/assets/image.png` path. 

For convenience all relative image assets are listed at the end of the import, to assist with the manual upload.

**Example Output**

    -------------------------------------------
        Import Ghost blog posts to Siteleaf.     
    -------------------------------------------
    
    importing post 1, 'Awesome blog post #1'...
    importing post 2, 'Awesome blog post #2'...
    importing post 3, 'Awesome blog post #3'...
    
    -------------------------------------------
     - 3 post(s) found in Ghost export
     - 3 post(s) successfully imported
     - relative path for 4 img assets updated  ☞  to be manually uploaded to Siteleaf:
       image1.png
       image2.png
       image3.jpg
       image4.jpg
    
    -------------------------------------------

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

[Siteleaf]: http://siteleaf.com/
[Siteleaf Gem]: https://github.com/siteleaf/siteleaf-gem
[Siteleaf API]: https://github.com/siteleaf/siteleaf-api
[Ghost]: http://ghost.org/
[Ruby]: http://www.ruby-lang.org/
[Bundler]: http://bundler.io/

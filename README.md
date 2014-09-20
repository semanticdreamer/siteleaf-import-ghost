# Import Ghost blog posts to Siteleaf.

Ruby import script for importing blog post from the [Ghost][Ghost] blogging platform into [Siteleaf][Siteleaf].

The script leverages the [Siteleaf Gem][Siteleaf Gem] for accessing the [Siteleaf API][Siteleaf API]. 

## Credits

Based on [sskylar](https://gist.github.com/sskylar)'s [Siteleaf import script](https://gist.github.com/sskylar/5824224).

## Features

The script will import the blog posts along w/ any local image assets from [Ghost][Ghost]'s `*.json` export file into a configurable (`config.yml`) Siteleaf site and page.

**Fields**

The following blog post fields are imported:

- `title`
- `status` (`published -> visible, draft -> draft`)
- `markdown` content/ body
- `published_at` date
- `tags`
- `assets`

**Asset Handling**

The relative image asset file paths (`![](/contents/images/.../image.png)`) from Ghost's `markdown` content are parsed and udpated to match Siteleaf's `/assets/image.png` path. 

The image asset files are then uploaded to Siteleaf and associated w/ the according posts. Also for convenience the files are stored in the directory provided for config option `assets_download_dir`.

**Test Mode (optional)**

If the config option `test_mode` is set to `true` (default `false`) neither posts nor assets are imported (saved).

**Example Output**

    -------------------------------------------
        Import Ghost blog posts to Siteleaf.     
    -------------------------------------------

    importing post 1, 'Awesome blog post #1'...
     - post.create SUCCESS: 1234567890abc123456789db
     - asset.create SUCCESS: image1.png
    importing post 2, 'Awesome blog post #2'...
     - post.create SUCCESS: 2234567890abc223456789db
    
    -------------------------------------------
    Total of 2 posts found in Ghost export.
     ☺ post import SUCCEEDED for 2 posts.
     ☺ asset upload SUCCEEDED for 1 assets.
    
    -------------------------------------------

## Prerequisites

- import target: [Siteleaf][Siteleaf] account, site and page
- export source: [Ghost][Ghost] (tested w/ **v0.4.2**) **Note:** site should still be online (for download of image assets in Ghost posts)
- [Ruby][Ruby] (tested w/ **v2.1.2**)
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

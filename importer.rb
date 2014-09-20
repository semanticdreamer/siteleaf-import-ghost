require "siteleaf"
require "json"
require 'open-uri'

config = YAML.load_file('config.yml')

# check configuration
if config['Siteleaf']['api_key'].nil? || config['Siteleaf']['api_secret'].nil?
  raise RuntimeError, "Importer requires valid Siteleaf API Credentials in the config.yml file."
end
if config['Siteleaf']['site_id'].nil? || config['Siteleaf']['page_id'].nil?
  raise RuntimeError, "Importer requires valid Siteleaf site settings in the config.yml file."
end
if !File.file?(config['Ghost']['export_file']) || config['Ghost']['site_url'].nil?
  raise RuntimeError, "Importer requires valid Ghost settings and *.json export in the config.yml file."
end

# Siteleaf API settings
Siteleaf.api_key = config['Siteleaf']['api_key']
Siteleaf.api_secret = config['Siteleaf']['api_secret']

# Siteleaf site settings
site_id = config['Siteleaf']['site_id']
page_id = config['Siteleaf']['page_id']

# Ghost export file
export_file = config['Ghost']['export_file']

test_mode = config['test_mode']

# get entries from JSON export
contents = JSON.parse(File.read(export_file))

siteleaf_assets = Array.new
success_posts_count = 0
failure_posts_count = 0
success_assets_count = 0
failure_assets_count = 0

puts "\n-------------------------------------------"
puts "    Import Ghost blog posts to Siteleaf.     "
puts "-------------------------------------------\n\n"

# loop through and add entries
contents['data']['posts'].each do |content|
  
  post_id = content["id"]
  post_title = content["title"]
  
  puts "importing post #{post_id}, '#{post_title}'..."
  
  # set up post
  post = Siteleaf::Post.new
  post.site_id = site_id
  post.parent_id = page_id
  
  # required
  post.title = post_title
  
  body_content = content["markdown"]
  # convert any relative Ghost image path, i.e. "/content/images/.../image.png"
  # within the markdown to a Siteleaf relative image path, i.e. "/assets/image.png"
  ghost_assets = Array.new
  body_content = body_content.gsub(/!\[([^\]]*)\]\((?!https?:\/\/)(.+)\)/) do |match|
    asset_file_path = $2
    ghost_assets << asset_file_path
    updated_image_path = File.join("/assets/", File.basename(asset_file_path))
    %{![#{$1}](#{updated_image_path})}
  end
  
  post.body = body_content
  
  # optional
  visibility = (content["status"] == 'published' ? 'visible' : 'draft')
  post.visibility = visibility
    
  # find all posts_tags by post_id
  tags = Array.new
  posts_tags = contents["data"]["posts_tags"].select { |h| h['post_id'] == post_id }
  if posts_tags.length > 0
    posts_tags.each do |post_tag|
      # get tag by tag_id
      tag = contents["data"]["tags"].select { |h| h['id'] == post_tag["tag_id"] }.first
      tags << tag["name"]
    end
    post.taxonomy = [
      {"key" => "Tags", "values" => tags}
    ]
  end
  
  post.published_at = content["published_at"]
  
  # save
  if !test_mode# && post_id == 28
    resp = post.save
    if resp.id
      puts " - post.create SUCCESS: " + resp.id
      success_posts_count += 1
      
      # fetch image assets...
      if ghost_assets.length > 0
        ghost_assets.each do |ghost_asset|
          open(File.join(config['assets_download_dir'], File.basename(ghost_asset)), 'wb') do |file|
            file << open(File.join(config['Ghost']['site_url'], ghost_asset)).read
          end
          # ... and upload asset, assoc. w/ post
          siteleaf_asset = Siteleaf::Asset.create({
            :post_id  => resp.id, 
            :file     => File.open(File.join(config['assets_download_dir'], File.basename(ghost_asset))), 
            :filename => File.basename(ghost_asset)
          })
          if siteleaf_asset.id
            siteleaf_assets << siteleaf_asset.url
            puts " - asset.create SUCCESS: " + File.basename(siteleaf_asset.url)
            success_assets_count += 1
          else
            puts " - asset.create ERROR!!!\n" + siteleaf_asset.inspect + "\n"
            failure_assets_count += 1
          end
        end
      end
      
    else
      puts " - post.create ERROR!!!\n" + resp.inspect + "\n"
      failure_posts_count += 1
    end
  end
  
end

# done!
puts "\n-------------------------------------------\n"
puts "Total of #{contents['data']['posts'].length} posts found in Ghost export.\n"
puts " ☺ post import SUCCEEDED for #{success_posts_count} posts."
puts "  ☹ post import FAILED for #{failure_posts_count} posts.\n" if failure_posts_count > 0
puts " ☺ asset upload SUCCEEDED for #{success_assets_count} assets."
puts "  ☹ asset upload FAILED for #{failure_assets_count} assets." if failure_assets_count > 0
puts "\n-------------------------------------------\n"
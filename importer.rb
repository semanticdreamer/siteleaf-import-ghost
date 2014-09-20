require "siteleaf"
require "json"

config = YAML.load_file('config.yml')

# check configuration
if config['Siteleaf']['api_key'].nil? || config['Siteleaf']['api_secret'].nil?
  raise RuntimeError, "Importer requires valid Siteleaf API Credentials in the config.yml file."
end
if config['Siteleaf']['site_id'].nil? || config['Siteleaf']['page_id'].nil?
  raise RuntimeError, "Importer requires valid Siteleaf site settings in the config.yml file."
end
if !File.file?(config['Ghost']['export_file'])
  raise RuntimeError, "Importer requires a valid Ghost *.json file in the config.yml file."
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

assets = Array.new
success_posts_count = 0
failure_posts_count = 0

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
  body_content = body_content.gsub(/!\[([^\]]*)\]\((?!https?:\/\/)(.+)\)/) do |match|
    asset_file = File.basename($2)
    assets << asset_file
    updated_image_path = File.join("/assets/", asset_file)
    %{![#{$1}](#{updated_image_path})}
  end 
  post.body = body_content
  
  # optional
  visibility = (content["status"] == 'published' ? 'visible' : 'draft')
  post.visibility = visibility
    
  # find all posts_tags by post_id
  tags = Array.new
  posts_tags = contents["data"]["posts_tags"].select { |h| h['post_id'] == post_id }
  if !posts_tags.length == 0
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
      puts "SUCCESS!"
      success_posts_count += 1
    else
      puts "ERROR\n" + resp.inspect + "\n"
      failure_posts_count += 1
    end
  end
  
end

# done!
puts "\n-------------------------------------------\n"
puts " - #{contents['data']['posts'].length} post(s) found in Ghost export"
puts " - import SUCCEEDED for #{success_posts_count} post(s)... :-)"
puts " - import FAILED for #{failure_posts_count} post(s)... :-("
puts " - relative path for #{assets.length} img assets updated  ☞  to be manually uploaded to Siteleaf:"
assets.each do |asset|
  puts "   #{asset}"
end
puts "\n-------------------------------------------\n"
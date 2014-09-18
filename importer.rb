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

# loop through and add entries
contents['data']['posts'].each do |content|
  puts "Creating post..."
  
  # set up post
  post = Siteleaf::Post.new
  post.site_id = site_id
  post.parent_id = page_id
  
  # required
  post.title = content["title"]
  post.body = content["markdown"]
  
  # optional
  visibility = (content["status"] == 'published' ? 'visible' : 'draft')
  post.visibility = visibility
  # post.taxonomy = [
  #   {"key" => "Tags", "values" => content["tags"]}
  # ]
  post.published_at = content["published_at"]
  
  # save
  puts test_mode ? post.inspect : post.save.inspect
end

# done!
puts "Success!"
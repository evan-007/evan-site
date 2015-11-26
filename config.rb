set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :blog do |blog|
  blog.sources = '/blog/{year}-{month}-{day}-{title}.html'
  blog.layout = 'blog_layout'
end
activate :directory_indexes
activate :dotenv
activate :syntax, line_numbers: true

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true


page "/404.html", directory_index: false


configure :build do
  activate :syntax
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

configure :development do
  activate :livereload
end

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = ENV['S3_BUCKET']
  s3_sync.region                     = ENV['S3_REGION']
  s3_sync.aws_access_key_id          = ENV['AWS_KEY_ID']
  s3_sync.aws_secret_access_key      = ENV['AWS_SECRET_KEY']
  s3_sync.delete                     = false # We delete stray files by default.
  s3_sync.after_build                = false # We do not chain after the build step by default.
  s3_sync.prefer_gzip                = true
  s3_sync.path_style                 = true
  s3_sync.reduced_redundancy_storage = false
  s3_sync.acl                        = 'public-read'
  s3_sync.encryption                 = false
# this puts the deploy in the top level bucket
#  s3_sync.prefix                     = ''
  s3_sync.version_bucket             = false
  s3_sync.error_document             = '404.html'
  s3_sync.index_suffix               = 'index.html'
end

# load rails_assets for frontend deps
after_configuration do
  if defined?(RailsAssets)
    RailsAssets.load_paths.each do |path|
      sprockets.append_path path
    end
  end
end

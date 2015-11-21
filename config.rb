set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

activate :bourbon
activate :neat
activate :directory_indexes

configure :development do
  activate :livereload
end

configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

# load rails_assets for frontend deps
after_configuration do
  if defined?(RailsAssets)
    RailsAssets.load_paths.each do |path|
      sprockets.append_path path
    end
  end
end

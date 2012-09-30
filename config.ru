require 'coffee_script'
require 'sass'

map '/' do
  require './app'
  run Sinatra::Application
end

map '/assets' do
  require 'sprockets'
  require 'yui/compressor'
  env = Sprockets::Environment.new
  env.append_path 'app/js'
  env.append_path 'app/css'
  env.append_path 'app/resources'

  # Compress JavaScript and shorten local variable names (:munge option)
  env.js_compressor = YUI::JavaScriptCompressor.new :munge => true #, :line_break => 80

  # Compress CSS.
  # Note: This is a horrible monkey-patching. Ass YUI compressor is not working
  # with our CSS, we use the :style option of Sass. Unfortunately, it can be
  # passed in a nice way because the Sass::Engine is instantiated by
  # Sprockets::SassTemplate.
  options = Sass::Engine::DEFAULT_OPTIONS.merge(:style => :compressed)
  Sass::Engine.send(:remove_const, :DEFAULT_OPTIONS)
  Sass::Engine.const_set(:DEFAULT_OPTIONS, options)
  # TODO Remove the above ugly monkey-path and add the next line when this
  # pull-request is closed: https://github.com/sstephenson/ruby-yui-compressor/pull/25
  # (and the gems are updated)
  # env.css_compressor = YUI::CssCompressor.new


  run env
end

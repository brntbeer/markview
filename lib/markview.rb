$:.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'sinatra'
require 'json'
require 'github/markup'

class Markview < Sinatra::Base
  dir = File.dirname(File.expand_path(__FILE__))

  set :views,  "#{dir}/markview/views"
  set :public, "#{dir}/markview/public"
  set :static, true

  before do
    @@markup = ARGV[0] ||= Dir.glob("README*")[0]
    unless File.file?(@@markup)
      raise LoadError, "Failed to open document. Please specify a file."; exit!
    end
  end

  # Renders the html using GitHub::Markup
  def self.render
    GitHub::Markup.render(@@markup, File.read(@@markup))
  end

	get '/file/:file' do
		@@markup = params[:file]
		@markdown = Markview.render
		erb :base
	end

  get '/' do
    @markdown = Markview.render
    @title = File.basename(@@markup)
    erb :base
  end

	get '/all' do
		@files = Dir.glob("*.md"),
			Dir.glob("*.mdown"), 
			Dir.glob("*.markdown")
		#
		#@markdown = Markview.render
		@title = "All The Files!"
		erb :all
	end

  get '/edit' do
    @markdown = File.read(@@markup)
    @title = File.basename(@@markup)
    erb :edit
  end

  post '/save' do
    return ({:error => true, :message => "Failed to save file!"}).to_json unless request['markup']
    File.open(@@markup, 'w') { |f| f.write(request['markup']) }
    ({:error => false, :message => "File succesfully saved!"}).to_json
  end

end
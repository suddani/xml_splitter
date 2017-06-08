require "bundler/setup"
require "xml_splitter"
require 'sinatra/base'
require 'rack'
require 'rack/contrib'

class App < Sinatra::Base
  get "/" do
    source_url = params["url"]
    xpath = params["xpath"]
    [source_url, xpath]
  end
end

run App

require "bundler/setup"
require "xml_splitter"
require 'sinatra/base'
require 'rack'
require 'rack/contrib'

class App < Sinatra::Base
  get "/" do
    source_url = params["url"]
    element = params["element"]||"entity"
    element_count = params["element_count"].to_i||1000
    username = params["username"]
    password = params["password"]

    fetcher = if source_url.match(/^http/)
      puts "Its html"
      XmlSplitter::HttpFetcher.new
    elsif source_url.match(/^ftp/)
      puts "Its ftp"
      XmlSplitter::FtpFetcher.new(username, password)
    else
      raise "Unknown type"
    end

    File.open("feed.xml", "w+") do |file|
      file.write fetcher.fetch_direct(source_url)
    end

    content_type :zip
    file = XmlSplitter::Splitter.new(element: element, element_count: element_count).run(input: "feed.xml")
    send_file file, :type => 'application/zip',
                         :disposition => 'attachment',
                         :filename => 'output.zip',
                         :stream => false
  end
end

run App

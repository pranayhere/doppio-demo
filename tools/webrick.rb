#! /usr/bin/env ruby
require 'webrick'
require 'optparse'

include WEBrick

def start(port)
  documentRoot = "#{File.dirname __FILE__}/.."

  puts "Creating server."

  mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
  mime_types.store 'svg', 'image/svg+xml'

  server = HTTPServer.new({:DocumentRoot => documentRoot,
                           :Port         => port,
                           :MimeTypes    => mime_types})

  ['INT', 'TERM'].each {|signal|
    trap(signal) { server.shutdown }
  }

  puts "Starting server."
  server.start()
end

if __FILE__ == $PROGRAM_NAME
  port = 8000
  op = OptionParser.new do |opts|
    opts.banner = "Usage: webrick.rb"
    opts.on("-p", "--port PORT", Integer, "Port for local server") do |p|
      port = p
    end
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
  op.parse! ARGV
  start(port)
end

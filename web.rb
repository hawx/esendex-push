require 'json'
require 'nokogiri'
require 'sinatra'
require 'time'

require_relative 'lib/deserialisable'
require_relative 'lib/data'

$connections = []
$notifications = []

set :public_folder, Proc.new { File.join(root, 'public') }
# set server: 'thin'

helpers do
  def raw
    request.env["rack.input"].read
  end

  def notify(event)
    $notifications << event

    $notifications.shift if $notifications.length > 10
    $connections.each {|out| out << "data: #{event.to_json}\n\n" }
  end
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/connect', provides: 'text/event-stream' do
  stream :keep_open do |out|
    $connections << out

    out.callback {
      $connections.delete(out)
    }
  end
end

post '/event/received' do
  notify InboundMessage.from_xml(raw); "ok"
end

post '/event/delivered' do
  notify MessageDelivered.from_xml(raw); "ok"
end

post '/event/failed' do
  notify MessageFailed.from_xml(raw); "ok"
end

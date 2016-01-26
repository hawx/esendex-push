require 'json'
require 'nokogiri'
require 'sinatra'
require 'time'

require_relative 'lib/deserialisable'
require_relative 'lib/data'
require_relative 'lib/soap'

$stdout.sync = true

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

post '/event/soap' do
  body = /<soap:Body>(.*?)<\/soap:Body>/.match(raw).captures[0]
    
  puts body
    
  notify case body
         when /<MessageError/ then SoapMessageError.from_xml(body)
         when /<MessageEvent/ then SoapMessageEvent.from_xml(body)
         when /<MessageReceived/ then SoapMessageReceived.from_xml(body)
         else {type: :other, msg: 'Missing soaps', at: Time.now}
         end
         
  "ok"
end

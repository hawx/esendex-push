# -*- coding: utf-8 -*-
require_relative 'deserialisable'
require 'sinatra'
require 'time'

class InboundMessage
  extend Deserialisable

  root 'InboundMessage'

  element :id, 'Id'
  element :message_id, 'MessageId'
  element :account_id, 'AccountId'
  element :message_text, 'MessageText'
  element :from, 'From'
  element :to, 'To'

  def to_json
    {
      type: :received,
      msg:  "Received message from #{from}",
      at:   Time.now
    }.to_json
  end
end

class MessageDelivered
  extend Deserialisable

  root 'MessageDelivered'

  element :id, 'Id'
  element :message_id, 'MessageId'
  element :account_id, 'AccountId'
  element :occurred_at, 'OccurredAt', Time

  def to_json
    {
      type: :delivered,
      msg:  "Delivered message",
      at:   occurred_at
    }.to_json
  end
end

class MessageFailed
  extend Deserialisable

  root 'MessageFailed'

  element :id, 'Id'
  element :message_id, 'MessageId'
  element :account_id, 'AccountId'
  element :occurred_at, 'OccurredAt', Time

  def to_json
    {
      type: :failed,
      msg:  "Failed sending message",
      at:   occurred_at
    }.to_json
  end
end

require 'json'

set :public_folder, Proc.new { File.join(root, 'public') }
set server: 'thin'

get '/' do
  erb :index
end

$connections = []
$notifications = []

get '/connect', provides: 'text/event-stream' do
  stream :keep_open do |out|
    $connections << out

    out.callback {
      $connections.delete(out)
    }
  end
end

post '/event/received' do
  raw = request.env["rack.input"].read

  notification = InboundMessage.from_xml(raw)
  $notifications << notification

  $notifications.shift if $notifications.length > 10
  $connections.each {|out| out << "data: #{notification.to_json}\n\n" }
end

post '/event/delivered' do
  raw = request.env["rack.input"].read

  notification = MessageDelivered.from_xml(raw)
  $notifications << notification

  $notifications.shift if $notifications.length > 10
  $connections.each {|out| out << "data: #{notification.to_json}\n\n" }
end

post '/event/failed' do
  raw = request.env["rack.input"].read

  notification = MessageFailed.from_xml(raw)
  $notifications << notification

  $notifications.shift if $notifications.length > 10
  $connections.each {|out| out << "data: #{notification.to_json}\n\n" }
end

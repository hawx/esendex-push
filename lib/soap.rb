class SoapMessageError
  extend Deserialisable

  root 'MessageError'

  element :id, 'id'
  element :error_type, 'errortype'
  element :occurred_at, 'occurredat'
  element :detail, 'detail'

  def to_json
    {
      type: :failed,
      msg:  '{SOAP} Failed sending message',
      at:   occurred_at || Time.now
    }.to_json
  end
end

class SoapMessageEvent
  extend Deserialisable

  root 'MessageEvent'

  element :id, 'id'
  element :event_type, 'eventtype'
  element :occurred_at, 'occurredat'

  def to_json
    {
      type: :delivered,
      msg:  '{SOAP} Delivered message',
      at:   occurred_at || Time.now
    }.to_json
  end
end

class SoapMessageReceived
  extend Deserialisable

  root 'MessageReceived'

  element :id, 'id'
  element :from, 'originator'
  element :to, 'recipient'
  element :body, 'body'
  element :type, 'type'
  element :sent_at, 'sentat'
  element :received_at, 'received_at'

  def to_json
    {
      type: :received,
      msg:  "Received message from #{from || "Unknown"}",
      at:   received_at || Time.now
    }.to_json
  end
end

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

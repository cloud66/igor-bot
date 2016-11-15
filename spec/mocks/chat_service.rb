class Lita::Adapters::Test::ChatService
  def send_attachment(room, attachments)
    @sent_messages << attachments
    @sent_messages.flatten!
  end
end
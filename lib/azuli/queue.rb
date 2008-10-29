module Azuli
   class Queue < QueueBase
      class << self
         def create(name, metadata = {})
            put(name, Metadata.to_meta(metadata))
         end
         def push(queue_name, message_text, options={})
            xml = Builder::XmlMarkup.new
            msg = xml.QueueMessage {
               xml.MessageText(message_text)
            }
            post(messages_path(queue_name), msg, options)
         end

         private
         def messages_path(queue_name)
            "/#{queue_name}/messages"
         end
      end
   end
end

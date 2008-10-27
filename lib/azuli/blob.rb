module Azuli
   class Blob < BaseObject
      attr_reader :container_name

      def initialize(connection, container_name, name, properties={})
         super(connection, name, properties)
         @container_name = container_name
         @content = (properties.respond_to? :body) ? properties.body : nil
      end

      def content_type
         get_prop('content-type')
      end
      def content_md5
         get_prop('content-md5')
      end
      def blob_path
         self.class.blob_path container_name, name
      end

      def update
         self.class.put_metadata blob_path, properties
      end
      def content(&block)
         if !@content or @content == '' then
            response = self.class.get_object blob_path
            @properties = response
            if block then
               response.read_body(&block)
            else
               @content = response.body
            end
         end
         @content
      end


      class << self
         def store(container_name, blob_name, content, properties={})
            actual_props = Metadata.fixup_meta properties
            Container.validate_name container_name
            response = put(blob_path(container_name, blob_name), actual_props, content)
            Blob.new(blob_connection, container_name, blob_name, response)
         end

         def blob_path(container_name, blob_name)
            "#{container_name}/#{URI.escape(blob_name)}"
         end

         def find(container_name, blob_name)
            path = blob_path(container_name, blob_name)
            get_props_or_nil(path) { |connection, response|
               if response then
                  Blob.new(connection, container_name, name, response)
               end
            }
         end

         def get(container_name, blob_name)
            blob = nil
            get_object(blob_path(container_name, blob_name)) { |connection, response|
               blob = Blob.new(connection, container_name, name, response)
            }
         end
      end
   end
end

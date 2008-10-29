module Azuli
   class BaseObject
      attr_reader :name, :properties

      def initialize(connection, name, headers)
         @name = name
         @properties = headers
         @connection = connection
      end

      def last_modified
         get_prop('last-modified')
      end
      def etag
         get_prop('etag') or properties['ETag']
      end
      def path
         @connection.make_path(name)
      end
      def get_meta(name)
         get_prop(Metadata.as_meta(name))
      end
      def set_meta(name, value)
         properties[find_prop_case(Metadata.as_meta(name))] = value.to_s
      end

      class << self
         def get_props_or_nil(path)
            connection = new_connection
            request = Azuli::Head.new connection.make_path(path)
            response = connection.do_request(request, [Net::HTTPNotFound])
            yield(connection, (response.kind_of?(Net::HTTPNotFound) ? nil : response))
         end
         def get_object(path, &block)
            connection = new_connection
            request = Azuli::Get.new connection.make_path(path)
            response = connection.do_request request
            if block then
               yield(connection, response)
            else
               response
            end
         end
         def put(path, properties, content=nil)
            connection = new_connection
            request = Azuli::Put.new(connection.make_path(path), properties)
            set_request_content(request, content)
            connection.do_request(request, [Net::HTTPConflict])
         end
         def post(path, content=nil, qstring={})
            connection = new_connection
            request = Azuli::Post.new(connection.make_path(path))
            set_request_content(request, content)
            request.add_qstring_params qstring
            connection.do_request request
         end
         def put_metadata(path, properties)
            connection = new_connection
            request = Azuli::Put.new(connection.make_path(path), properties)
            request.comp = 'metadata'
            connection.do_request request
         end
         def delete(path)
            connection = new_connection
            request = Azuli::Delete.new(connection.make_path(path))
            connection.do_request request
         end
         def get_list(path, options={})
            connection = new_connection
            request = Azuli::Get.new(connection.make_path(path))
            request.comp = 'list'
            request.add_qstring_params options
            connection.do_request request
         end
         private
         def set_request_content(request, content)
            if !request.nil? then
               if content.kind_of? File then
                  request.body_stream = content
               else
                  request.body = content
               end
               if !request['Content-Type'] then
                  infer_content_type(request, content)
               end
            end
         end
         def infer_content_type(request, content)
            if !content.nil? then
               if content.kind_of? String then
                  request.content_type = 'text/plain'
               else
                  types = MIME::Types.type_for content.path
                  request.content_type = types.length > 0 ? types[0].to_s : 'text/plain'
               end
            end
         end
      end

      private
      def get_prop(name)
         properties[name] or properties[name.downcase] or properties[canonicalize(name)]
      end
      def find_prop_case(name)
         if properties.key?(name) then
            name
         elsif properties.key?(name.downcase) then
            name.downcase
         else
            canonicalize(name)
         end
      end
      def canonicalize(name)
         # cool trick from Net::Http
         name.split(/-/).map {|s| s.capitalize }.join('-')
      end
   end

   class BlobBase < BaseObject
      def self.new_connection
         Connection.get_blob_connection
      end
   end
   class QueueBase < BaseObject
      def self.new_connection
         Connection.get_queue_connection
      end
   end
end

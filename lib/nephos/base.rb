module Nephos
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

      def self.get_props_or_nil(path)
         connection = Connection.get_blob_connection
         request = Nephos::Head.new connection.make_path(path)
         response = connection.do_request(request, [Net::HTTPNotFound])
         yield(connection, (response.kind_of?(Net::HTTPNotFound) ? nil : response))
      end
      def self.put(path, properties)
         connection = Connection.get_blob_connection
         request = Nephos::Put.new(connection.make_path(path), properties)
         connection.do_request(request, [Net::HTTPConflict])
      end
      def self.put_metadata(path, properties)
         connection = Connection.get_blob_connection
         request = Nephos::Put.new(connection.make_path(path), properties)
         request.comp = 'metadata'
         connection.do_request request
      end
      def self.delete(path)
         connection = Connection.get_blob_connection
         request = Nephos::Delete.new(connection.make_path(path))
         connection.do_request request
      end
      def self.get_list(path, options={})
         connection = Connection.get_blob_connection
         request = Nephos::Get.new(connection.make_path(path))
         request.comp = 'list'
         request.add_qstring_params options
         connection.do_request request
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
end

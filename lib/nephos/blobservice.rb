module Nephos
   class BlobService < Base
      def initialize(options)
         connection_options(options[:blob_service], options)
      end

      # TODO: add metadata properties
      def create_container(name, public_access = true, metadata = {})
         request = Nephos::Put.new request_path(name)
         request.add_metadata metadata
         request.set_property :publicaccess, public_access

         connection = new_connection request
         response = connection.do_request
         # if container already exist, that's fine
         check_response response, true

         find_container name
      end

      def find_container(name)
         # TODO: implement
         Container.new name
      end
   end
end

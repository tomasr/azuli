module Nephos
   class BlobService < Base
      attr_reader :last_marker

      def initialize(options)
         connection_options(options[:blob_service], options)
         @last_marker = nil
      end

      def create_container(name, public_access = true, metadata = {})
         Container.validate_name name

         request = Nephos::Put.new request_path(name)
         request.add_metadata metadata
         request.set_property :publicaccess, public_access

         connection = new_connection
         connection.do_request(request, true)
      end

      def find_container(name)
         request = Nephos::Head.new request_path(name)
         connection = new_connection
         response = connection.do_request request

         Container.new(name, url_for(name), response)
      end

      def list_containers(options = {})
         connection = new_connection
         @last_marker = nil if !(options[:continue])
         containers = []
         @last_marker = do_list_containers(connection, options, containers)
         containers
      end

      private
      def do_list_containers(connection, options, containers)
         request = Nephos::Get.new request_path('')
         request.comp = 'list'
         request.add_qstring_params options
         request.add_qstring('marker', last_marker) if last_marker

         response = connection.do_request request

         list_xml = XmlSimple.xml_in(response.body, 'ForceArray' => false)
         containers.concat extract_containers(list_xml)

         new_marker = list_xml['NextMarker']
         new_marker == {} ? nil : new_marker
      end
      def extract_containers(list)
         containers = list['Containers']
         if containers.length > 0 then
            parsed = containers['Container'].map { |container|
               Container.from_list(container)
            }
         end
         parsed or []
      end
   end
end

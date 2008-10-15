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

         connection = new_connection
         connection.do_request(request, true)
         find_container name
      end

      def find_container(name)
         # TODO: implement
         Container.new({'Name' => name})
      end

      def list_containers
         connection = new_connection
         marker = nil
         containers = []
         until marker == '' do
            marker = do_list_containers(connection, marker, containers)
         end
         containers
      end

      private
      def do_list_containers(connection, marker, containers)
         request = Nephos::Get.new request_path('')
         request.comp = 'list'
         request.add_qstring('marker', marker) if marker

         response = connection.do_request request

         list_xml = XmlSimple.xml_in(response.body, 'ForceArray' => false)
         containers.concat extract_containers(list_xml)

         new_marker = list_xml['NextMarker']
         new_marker == {} ? '' : new_marker[0]
      end
      def extract_containers(list)
         parsed = list['Containers']['Container'].map { |container|
            Container.new(container)
         }
      end
   end
end

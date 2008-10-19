module Nephos
   class Container < BaseObject

      # update the metadata associated with this container
      def update
         Container.put_metadata(name, properties)
      end
      def delete!
         Container.delete name
      end
      def reload!
         Container.get_props_or_nil(name) { |connection, response|
            if response then
               @properties = response
            end
         }
      end

      class << self
         def find(name)
            container = nil
            get_props_or_nil(name) { |connection, response|
               if response then
                  container = Container.new(connection, name, response)
               end
            }
         end
         def create(name, public_access = true, metadata = {})
            validate_name name
            properties = { 'x-ms-prop-publicaccess' => public_access.to_s }
            properties.merge!(Metadata.to_meta(metadata))
            put(name, properties)
         end
         # list containers on the account
         # Available options are:
         # :marker => start the enumeration from this value
         # :maxresults => only return up to this number of results
         def list(options = {})
            xml = Parser.get(get_list('', options).body)
            marker = xml['NextMarker']
            ListResult.new((marker == {} ? nil : marker), parse_list(xml))
         end

         def validate_name(name)
            raise InvalidContainerName.new if name.length < 3
            raise InvalidContainerName.new if name.length > 63
            raise InvalidContainerName.new if !(name =~ /^[a-z0-9\.\-]*$/)
            raise InvalidContainerName.new if name =~ /\.\-/
         end

         def from_list(properties = {})
            Container.new(properties['Name'], properties['Url'], properties)
         end

         private
         def parse_list(xml)
            containers = xml['Containers']
            if containers.length > 0 then
               parsed = containers['Container'].map { |container|
                  Container.from_list(container)
               }
            end
            parsed or []
         end
      end
   end

   class ListResult < Array
      attr_reader :marker

      def initialize(marker, values)
         super(values)
         @marker = marker
      end
   end

   class InvalidContainerName < Exception
   end
end

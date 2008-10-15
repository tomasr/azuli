module Nephos
   class Container
      def initialize(props = {})
         @properties = (props or {})
      end
      def name
         @properties['Name']
      end
      def url
         @properties['Url']
      end
      def last_modified
         @properties['LastModified']
      end
      def etag
         @properties['Etag']
      end

      def self.validate_name(name)
         raise InvalidContainerName.new if name.length < 3
         raise InvalidContainerName.new if name.length > 63
         raise InvalidContainerName.new if !(name =~ /^[a-z0-9\.\-]*$/)
         raise InvalidContainerName.new if name =~ /\.\-/
      end
   end

   class InvalidContainerName < Exception
   end
end

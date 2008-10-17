module Nephos
   class Container
      attr_reader :name, :url, :last_modified, :etag

      def initialize(name, uri, props={})
         @metadata = Metadata.new(props)
         @name = name
         @url = uri
         extract_properties!(props)
      end

      def has_metadata?
         @metadata.nil?
      end
      def metadata(name)
         @metadata[name.downcase]
      end


      def self.validate_name(name)
         raise InvalidContainerName.new if name.length < 3
         raise InvalidContainerName.new if name.length > 63
         raise InvalidContainerName.new if !(name =~ /^[a-z0-9\.\-]*$/)
         raise InvalidContainerName.new if name =~ /\.\-/
      end

      def self.from_list(properties = {})
         Container.new(properties['Name'], properties['Url'], properties)
      end

      private
      def extract_properties!(props)
         date = (props['Last-Modified'] or props['LastModified'])
         @last_modified = Time.rfc2822(date)
         @etag = (props['Etag'] or props['ETag'])
      end

   end

   class InvalidContainerName < Exception
   end
end

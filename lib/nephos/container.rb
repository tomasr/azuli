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

   end
end

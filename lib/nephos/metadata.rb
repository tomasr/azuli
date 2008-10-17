module Nephos

   class Metadata < Hash
      META_PREFIX = 'x-ms-meta-'

      def initialize(headers = {})
         super()
         extract_metadata!(headers)
      end
      def self.is_meta(name)
         name =~ Regexp.new(META_PREFIX)
      end
      def self.no_meta(name)
         name.downcase.slice(META_PREFIX.length, name.length-META_PREFIX.length)
      end
      def self.as_meta(name)
         META_PREFIX + name
      end

      private
      def extract_metadata!(headers)
         headers.each_key { |key|
            self[Metadata.no_meta(key)] = headers[key] if Metadata.is_meta(key)
         }
      end
   end
end

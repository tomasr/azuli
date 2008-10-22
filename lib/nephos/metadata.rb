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
         name.slice(META_PREFIX.length, name.length-META_PREFIX.length).capitalize
      end
      def self.as_meta(name)
         META_PREFIX + name
      end
      def self.to_meta(properties = {})
         meta = {}
         properties.each_pair { |key,value|
            meta[self.as_meta(key)] = value.to_s
         }
         meta
      end
      def self.fixup_meta(properties = {})
         meta = {}
         properties.each_pair { |key,value|
            if !is_http_prop(key.to_s) then
               meta[self.as_meta(key)] = value.to_s
            else
               meta[key.to_s] = value.to_s
            end
         }
         meta
      end

      private
      def self.is_http_prop(key)
         http = [
            'content-encoding',
            'content-language',
            'content-length',
            'content-md5',
            'content-range',
            'content-type',
            'etag',
            'host',
            'last-modified',
            'range',
         ]
         http.include? key.downcase
      end
      def extract_metadata!(headers)
         headers.each_key { |key|
            self[Metadata.no_meta(key)] = headers[key] if Metadata.is_meta(key)
         }
      end
   end
end

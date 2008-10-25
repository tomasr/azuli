module Nephos

   class NephosUri
      attr_accessor :base_url, :account, :shared_key
      attr_accessor :timeout, :name, :use_path_uri
      DEFAULT = 'default'

      def initialize(options)
         @name = options[:name]
         @base_url = URI.parse options[:url]
         @account = options[:account]
         @shared_key = options[:shared_key]
         @timeout = options[:timeout]
         @use_path_uri = options[:use_path_uri]
         @base_url.host = @account + '.' + @base_url.host unless @use_path_uri
      end

      def self.blob(options)
         default_opts = {
            :url => 'http://blob.core.windows.net/',
            :name => DEFAULT,
            :timeout => 30
         }
         NephosUri.new(default_opts.merge(options))
      end

      def host
         @base_url.host
      end
      def port
         @base_url.port
      end
      def operation(op)
         @comp = op
      end
      def connect_url
         @base_url.normalize
      end
   end

end

module Nephos

   class NephosUri
      attr_accessor :base_url, :account, :shared_key
      attr_accessor :timeout, :other_options

      def initialize(base_url, account, shared_key)
         @base_url = URI.parse base_url
         @account = account
         @shared_key = shared_key
         @timeout = 30
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
      def other_options(options)
         @other_options = options
      end
      def connect_url
         @base_url.normalize
      end
   end

end

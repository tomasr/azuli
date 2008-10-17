module Nephos
   class Base
      def connection_options(svc_base_url, options = {})
         conn_options = { 
            :base_url => svc_base_url
         }
         conn_options.update options
         @uri = NephosUri.new svc_base_url, options[:account], options[:shared_key]
      end

      def new_connection
         Connection.new @uri
      end

      def request_path(partial_path)
         '/' + @uri.account + '/' + partial_path
      end

      def url_for(partial_path)
         @uri.base_url + request_path(partial_path)
      end

   end

end

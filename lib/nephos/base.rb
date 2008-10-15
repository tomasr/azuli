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
         '/' + @uri.account + '/' + partial_path # TODO: Add qstring
      end

      def check_response(response, allow_conflict = false)
         if response.kind_of? Net::HTTPSuccess then
            # nothing
         elsif allow_conflict and response.kind_of? Net::HTTPConflict then
            # nothing
         elsif response.content_type == 'application/xml' then
            raise NephosException.new(response.body)
         else
            response.value() # force error
         end
      end
   end

   class NephosException < Exception
      attr_reader :code, :exception_message, :stack_trace
      def initialize(error_xml)
         error = XmlSimple.xml_in(error_xml)
         @code = error['Code']
         details = error['ExceptionDetails'][0]
         if details then
            @exception_message = details['ExceptionMessage']
            @stack_trace = details['StackTrace']
         end
         super error['Message']
      end
   end
end

module Azuli

   class AzureRequest < Net::HTTPRequest
      attr_reader :signable_path
      def comp
         qstring_args['comp']
      end
      def comp=(operation)
         qstring_args['comp'] = operation
      end
      def add_qstring(name, value)
         qstring_args[name.to_s] = value.to_s
      end
      def add_qstring_params(params)
         params.each_pair { |key,value|
            add_qstring(key, value)
         }
      end
      def add_metadata(metadata)
         metadata.each_pair { |key,value|
            set_metadata(key, value)
         }
      end
      def set_metadata(name, value)
         self[Metadata.as_meta(name.to_s)] = value.to_s
      end
      def metadata
         metaprops = {}
         headers.each_key { |key|
            metaprops[key] = self[key] if Metadata.is_meta(key)
         }
         metaprops
      end
      def set_property(name, value)
         self['x-ms-prop-' + name.to_s] = value.to_s
      end
      # Complete request so that headers make sense
      def complete
         @signable_path = save_path
         @path = build_real_path

         if method == 'PUT' and !body then
            self['content-length'] = 0
         end
         self['x-ms-date'] = Time.now.httpdate
      end

      private
      def build_real_path
         qpairs = []
         qstring_args.each_pair { |key,value|
            qpairs << key + '=' + URI.escape(value)
         }
         if qpairs.length > 0 then
            path + '?' + qpairs.join('&')
         else
            path
         end
      end
      def qstring_args
         @qstring = {} if !@qstring
         @qstring
      end
      def save_path
         spath = String.new path
         spath << '?comp=' + comp if comp
         spath
      end
   end
   class Put < AzureRequest
      METHOD = 'PUT'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
   end
   class Post < AzureRequest
      METHOD = 'POST'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
   end
   class Get < AzureRequest
      METHOD = 'GET'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = true
   end
   class Head < AzureRequest
      METHOD = 'HEAD'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
   end
   class Delete < AzureRequest
      METHOD = 'DELETE'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
   end

   class Connection
      class << self
         def set_blob_connection(options = {})
            @blob_connections ||= {}
            uri = AzureUri.blob(options)
            @blob_connections[uri.name] = Connection.new(uri)
         end
         def get_blob_connection(name = nil)
            @blob_connections ||= {}
            @blob_connections[(name or AzureUri::DEFAULT)]
         end
         def set_queue_connection(options = {})
            @queue_connections ||= {}
            uri = AzureUri.queue(options)
            @queue_connections[uri.name] = Connection.new(uri)
         end
         def get_queue_connection(name = nil)
            @queue_connections ||= {}
            @queue_connections[(name or AzureUri::DEFAULT)]
         end
      end

      def initialize(uri)
         @uri = uri
         @http = http_class.new(@uri.host, @uri.port)
      end

      def make_path(path)
         if @uri.use_path_uri then
            "/#{@uri.account}/#{path}"
         else
            "/#{path}"
         end
      end

      def do_request(request, allowed_responses = [], &block)
         request.add_qstring 'timeout', @uri.timeout
         request.complete

         HMACAuth.authorize request, @uri.account, @uri.shared_key

         @http.request(request) { |response|
            check_response response, allowed_responses
            if block then
               response.read_body &block
            end
            response
         }
      end

      def http_class
         # TODO: add proxy support
         Net::HTTP
      end

      def check_response(response, allowed_responses = [])
         if response.kind_of? Net::HTTPSuccess then
            # nothing
         elsif is_of_type(response, allowed_responses) then
            # nothing
         elsif response.content_type == 'application/xml' then
            raise AzureException.from_xml(response.body)
         else
            raise AzureException.from_http(response)
         end
      end
      private

      def is_of_type(response, allowed_responses)
         allowed_responses.any? { |resp| response.kind_of?(resp) }
      end
   end

   class AzureException < Exception
      attr_reader :code
      def initialize(code, message)
         @code = code
         super(message)
      end

      def self.from_xml(error_xml)
         error = XmlSimple.xml_in(error_xml)
         AzureException.new(error['Code'], error['Message'])
      end
      def self.from_http(response)
         AzureException.new(response.code, response.message)
      end
   end
end

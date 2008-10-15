# based on the Cloud Computing SDK documentation and
# partially on the auth-hmac library 
# http://github.com/seangeo/auth-hmac
module Nephos
   class HMACAuth
      AUTHORIZATION_HEADER = 'Authorization'
      CONTENT_TYPE = 'Content-Type'
      CONTENT_MD5 = 'Content-MD5'

      # Add authorization headers to the HTTPRequest object
      # The request should not be modified after this
      def self.authorize(request, account, shared_key)
         if !request[AUTHORIZATION_HEADER] then
            request[AUTHORIZATION_HEADER] = build_auth_header(request, account, shared_key)
         end
      end

      private
      def self.build_auth_header(request, account, shared_key)
         'SharedKey ' + account + ':' + sign(request, account, shared_key)
      end

      def self.sign(request, account, shared_key)
         to_sign = CanonicalString.new(request, account)
         decoded_key = Base64::decode64(shared_key)

         digest = OpenSSL::Digest::Digest.new('sha256')
         Base64.encode64(OpenSSL::HMAC.digest(digest, decoded_key, to_sign)).strip
      end

      class CanonicalString < String
         def initialize(request, account)
            self << request.method + "\n"
            self << content_md5(request) + "\n"
            self << content_type(request) + "\n"
            self << date_header(request) + "\n"
            self << header_values(request) + "\n"
            self << request_path(request, account)
         end

         private
         def content_md5(headers)
            headers['CONTENT-MD5'] or ''
         end
         def content_type(headers)
            headers.content_type or ''
         end
         def date_header(headers)
            date = headers['X-MS-DATE'] or headers['DATE']
            if date then
               ''
            else
               date
            end
         end
         def header_values(headers)
            metas = []
            headers.each_key { |key|
               metas << key if key.to_s =~ /^x-ms-/
            }
            metas.sort!
            str = ''
            metas.each_index { |index|
               str << metas[index].downcase + ':' + headers[metas[index]].strip()
               str << "\n" if index < metas.length() - 1
            }
            str
         end
         def request_path(request, account)
            '/' + account + request.signable_path
         end
      end
   end
end

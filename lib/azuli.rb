require 'base64'
require 'uri'
require 'openssl'
require 'digest/sha2'
require 'net/https'
require 'time'
require 'date'
require 'open-uri'
require 'xmlsimple'
require 'mime/types'

$:.unshift(File.dirname(__FILE__))

require 'Azuli/parser'
require 'Azuli/auth'
require 'Azuli/metadata'
require 'Azuli/azureuri'
require 'Azuli/connection'
require 'Azuli/base'
require 'Azuli/container'
require 'Azuli/blob'

module Azuli
   def self.blob_service(options = {})
      BlobService.new(options)
   end

   # set up connection to the Azuli blob services
   # valid options include:
   # :name => the name of the connection. If empty, sets default connection
   # :url => the base url of the service without the account name. Default value is http://blob.core.windows.net/
   # :account => the Azuli account name
   # :shared_key => the Azuli shared key
   # :timeout => the default timeout for operations
   # :use_path_uri => If true, use path-style URIs, necessary when working against the SDK services
   def self.set_connection(options)
      Connection.set_blob_connection options
   end
end


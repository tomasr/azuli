require 'base64'
require 'uri'
require 'openssl'
require 'digest/sha2'
require 'net/https'
require 'time'
require 'date'
require 'open-uri'
require 'xmlsimple'

$:.unshift(File.dirname(__FILE__))

require 'nephos/parser'
require 'nephos/auth'
require 'nephos/metadata'
require 'nephos/nephosuri'
require 'nephos/connection'
require 'nephos/base'
require 'nephos/container'
require 'nephos/blob'

module Nephos
   def self.blob_service(options = {})
      BlobService.new(options)
   end

   # set up connection to the nephos blob services
   # valid options include:
   # :name => the name of the connection. If empty, sets default connection
   # :url => the base url of the service. example: http://blob.windows.net/
   # :account => the nephos account name
   # :shared_key => the nephos shared key
   # :timeout => the default timeout for operations
   def self.set_connection(options)
      Connection.set_blob_connection options
   end
end


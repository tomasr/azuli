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

require 'nephos/auth'
require 'nephos/metadata'
require 'nephos/nephosuri'
require 'nephos/connection'
require 'nephos/base'
require 'nephos/blobservice'
require 'nephos/container'

module Nephos
   def self.blob_service(options = {})
      BlobService.new(options)
   end
end


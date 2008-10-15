require 'test/unit'
require File.dirname(__FILE__) + '/../lib/nephos'

class Test::Unit::TestCase
   include Nephos
   def get_blob_service
      options = {
         :account => 'testaccount1',
         :shared_key => 'FjUfNl1KiJttbXlsdkMzBTC7WagvrRM9/g6UPBuy0ypCpAbYTL6/KA+dI/7gyoWvLFYmah3IviUP1jykOHHOlA==',
         :blob_service => 'http://localhost:8081',
         :timeout => 30
      }
      Nephos.blob_service options
   end
end

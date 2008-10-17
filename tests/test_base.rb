require 'test/unit'
require File.dirname(__FILE__) + '/../lib/nephos'

class Test::Unit::TestCase
   include Nephos

   def setup
      @options = {
         :account => 'testaccount1',
         :shared_key => 'FjUfNl1KiJttbXlsdkMzBTC7WagvrRM9/g6UPBuy0ypCpAbYTL6/KA+dI/7gyoWvLFYmah3IviUP1jykOHHOlA==',
         :url => 'http://localhost:8081'
      }
      Connection.set_blob_connection @options
   end

   def new_object_name
      "x%x" % (rand() * 10000000)
   end

end

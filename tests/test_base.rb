require 'test/unit'
require File.dirname(__FILE__) + '/../lib/azuli'

class Test::Unit::TestCase
   include Azuli

   def setup
      @options = {
         :account => 'devstoreaccount1',
         :shared_key => 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==',
         :url => 'http://localhost:10000',
         :use_path_uri => true
      }
      Connection.set_blob_connection @options
   end

   def new_object_name
      "x%x" % (rand() * 10000000)
   end

end

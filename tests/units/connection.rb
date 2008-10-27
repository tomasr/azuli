#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestConnection < Test::Unit::TestCase

   def test_gets_right_host_name_with_host_style_uri
      uri = AzureUri.new({ 
         :url => 'http://blob.core.windows.net',
         :account => 'devstoreaccount1',
         :use_path_uri => false
      })
      assert_equal('devstoreaccount1.blob.core.windows.net', uri.host)
   end
   def test_gets_right_host_name_with_path_style_uri
      uri = AzureUri.new({ 
         :url => 'http://blob.core.windows.net',
         :account => 'devstoreaccount1',
         :use_path_uri => true
      })
      assert_equal('blob.core.windows.net', uri.host)
   end
   def test_request_gets_path_right_with_host_style_uri
      uri = AzureUri.new({ 
         :url => 'http://blob.core.windows.net',
         :account => 'devstoreaccount1',
         :use_path_uri => false
      })
      connection = Connection.new uri
      assert_equal('/path', connection.make_path('path'))
   end
   def test_request_gets_path_right_with_path_style_uri
      uri = AzureUri.new({ 
         :url => 'http://blob.core.windows.net',
         :account => 'devstoreaccount1',
         :use_path_uri => true
      })
      connection = Connection.new uri
      assert_equal('/devstoreaccount1/path', connection.make_path('path'))
   end
end


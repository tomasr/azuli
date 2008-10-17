#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestBlobService < Test::Unit::TestCase

   def setup
      @svc = get_blob_service
   end

   def test_can_create_container
      name = "x%x" % (rand() * 10000000)
      assert_nothing_raised { 
         @svc.create_container name, true, { :prop1 => 'value' }
      }
   end

   def test_can_list_containers
      list = @svc.list_containers
      assert(list.length > 0)
      assert_not_nil(list[0].name)
      assert_not_nil(list[0].url)
      assert_not_nil(list[0].last_modified)
      assert_not_nil(list[0].etag)
   end
   def test_can_list_containers_with_prefix
      list = @svc.list_containers :prefix => 'doesntexist'
      assert_equal(0, list.length)
   end
   def test_can_list_containers_with_max_results
      list = @svc.list_containers :maxresults => 5
      assert((list.length > 0 and list.length < 6))
      assert_not_nil(@svc.last_marker)
   end

   def test_can_find_container
      name = "x%x" % (rand() * 10000000)
      @svc.create_container name
      container = @svc.find_container name
      assert_not_nil(container)
   end
end


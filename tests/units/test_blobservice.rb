#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestBlobService < Test::Unit::TestCase

   def setup
      @svc = get_blob_service
   end

   def test_can_create_container
      name = "0x%x" % (rand() * 10000000)
      container = @svc.create_container name, true, { :prop1 => 'value' }
      assert_equal(name, container.name)
   end

   def test_can_list_containers
      list = @svc.list_containers
      assert(list.length > 0)
      assert_not_nil(list[0].name)
      assert_not_nil(list[0].url)
      assert_not_nil(list[0].last_modified)
      assert_not_nil(list[0].etag)
   end
end


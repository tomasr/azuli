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
      assert_greater(list.length, 0)
   end
end


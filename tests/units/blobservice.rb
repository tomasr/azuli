#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestBlobService < Test::Unit::TestCase

   def setup
      @svc = get_blob_service
   end

   def test_can_create_container
      name = new_object_name
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
      name = new_object_name
      @svc.create_container name

      container = @svc.find_container name
      assert_not_nil(container)
      assert_match(%r{http://.*/testaccount1/}, container.url.to_s)
   end
   def test_find_container_returns_null_if_not_found
      container = @svc.find_container 'will_not_exists_in_store'
      assert_nil(container)
   end

   def test_can_delete_container_by_name
      name = new_object_name
      @svc.create_container name

      assert_nothing_raised {
         @svc.delete name
      }
      assert_nil(@svc.find_container(name))
   end

   def test_can_set_container_metadata
      name = new_object_name
      @svc.create_container name
      container = @svc.find_container name
      container.metadata.merge!({ 'Prop1' => 'value1', 'Prop2' => 'value2' })
      @svc.update_metadata container

      container = @svc.find_container name
      assert_equal('value1', container.metadata['Prop1'])
      assert_equal('value2', container.metadata['Prop2'])
   end

   private
end


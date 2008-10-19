#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestContainer < Test::Unit::TestCase

   def test_validates_names
      valid_names = %w(lowercase withnum3rs with.dots with-dash)
      invalid_names = ['WithUpperCase', 'With Spaces', 'Dot.-Dash', 'aa', 'l'*64]
      valid_names.each { |name|
         assert_nothing_raised { Container.validate_name(name) }
      }
      invalid_names.each { |name|
         assert_raises(InvalidContainerName) { Container.validate_name(name)}
      }
   end

   def test_create_from_http_headers
      headers = {
         'Last-Modified' => 'Fri, 17 Oct 2008 01:19:04 GMT',
         'ETag' => '0x8CAFE0D7AF4A4C0',
         # a metadata property
         'x-ms-meta-Prop1' => 'Property1',
         # an unrelated header
         'Server' => 'Nephos Blob Service Version 1.0 Microsoft-HTTPAPI/2.0',
      }
      container = Container.new(nil, 'test1', headers)
      assert_equal('test1', container.name)
      assert_equal('0x8CAFE0D7AF4A4C0', container.etag)

      assert_equal('Property1', container.get_meta('Prop1'))
   end

   def test_can_create_container
      name = new_object_name
      assert_nothing_raised { Container.create(name) }
   end
   def test_can_find_container
      name = new_object_name
      Container.create(name)
      assert_not_nil(Container.find(name))
   end
   def test_can_delete_container_by_name
      name = new_object_name
      Container.create(name)
      assert_nothing_raised { Container.delete(name) }
   end
   def test_can_delete_container_instance
      name = new_object_name
      Container.create(name)
      container = Container.find name
      assert_nothing_raised { container.delete! }
   end
   def test_can_list_containers
      containers = Container.list
      assert_not_nil(containers)
   end
   def test_can_list_containers_with_max_results
      containers = Container.list :maxresults => 5
      assert(containers.length > 0)
      assert(containers.length <= 5)
      assert_not_nil(containers.marker)
   end
   def test_can_update_metadata
      name = new_object_name
      Container.create(name)
      container = Container.find(name)
      container.set_meta('prop2', 'Property2')
      container.update

      container = Container.find(name)
      assert_equal('Property2', container.get_meta('prop2'))
   end
   def test_can_reload
      name = new_object_name
      Container.create(name)
      container = Container.find(name)
      container.set_meta('prop2', 'Property2')
      etag = container.etag
      container.update

      container.reload!
      assert_not_equal(container.etag, etag)
   end
end


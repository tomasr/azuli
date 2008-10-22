#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestBlob < Test::Unit::TestCase

   def setup
      super()
      @folder = "blobs0x2134"
      Container.create @folder
      @text = 'This is the content of a blob'
   end

   def test_can_store_blob
      name = new_object_name
      assert_nothing_raised { Blob.store(@folder, name, @text) }
   end
   def test_validates_container_name_on_store
      name = new_object_name
      assert_raises(InvalidContainerName) { Blob.store('055Invalid.=name', name, @text) }
   end
   def test_blob_names_are_escaped_on_create
      name = 'prefix/' + new_object_name + ' finally.txt'
      assert_nothing_raised { Blob.store(@folder, name, @text) }
   end
   def test_can_store_blob_from_file
      name = new_object_name
      content = File.open '../content/logo.gif'
      assert_nothing_raised { Blob.store(@folder, name, content) }
   end
   def test_store_blob_returns_props
      name = new_object_name
      blob = Blob.store(@folder, name, @text)
      assert_not_nil(blob)
      assert_not_nil(blob.content_md5)
      assert_not_nil(blob.etag)
      assert_equal(@folder, blob.container_name)
      assert_equal(name, blob.name)
   end
   def test_can_get_blob_properties
      name = new_object_name
      props = { 'Content-Type' => 'text/xml', 'prop1' => 'value1' }
      Blob.store(@folder, name, @text, props)
      blob = Blob.find(@folder, name)
      assert_not_nil(blob)
      assert_equal('text/xml', blob.content_type)
      assert_equal('value1', blob.get_meta('prop1'))
   end
end

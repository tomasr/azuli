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
end

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
      container = Container.new('test1', '', headers)
      assert_equal('test1', container.name)
      assert_equal('test1', container.path)
      assert_equal('0x8CAFE0D7AF4A4C0', container.etag)

      assert_equal('Property1', container.metadata['Prop1'])
   end
end


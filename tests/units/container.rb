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
end


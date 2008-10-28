#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestQueue < Test::Unit::TestCase

   def test_can_create
      assert_nothing_raised { Queue.create new_object_name }
   end
end

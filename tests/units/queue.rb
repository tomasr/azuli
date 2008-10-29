#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_base'

class TestQueue < Test::Unit::TestCase

   def test_can_create
      assert_nothing_raised { Queue.create new_object_name }
   end
   def test_can_push
      name = new_object_name
      Queue.create name
      assert_nothing_raised { Queue.push name, "This is the message text" }
   end
   def test_can_push_with_ttl
      name = new_object_name
      Queue.create name
      assert_nothing_raised { Queue.push name, "This is the message text", { :messagettl => 5 } }
   end
end

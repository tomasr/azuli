module Nephos
   class Container
      def initialize(name)
         @properties = { :name => name }
      end
      def name 
         @properties[:name]
      end
   end
end

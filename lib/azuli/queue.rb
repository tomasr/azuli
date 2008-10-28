module Azuli
   class Queue < QueueBase
      class << self
         def create(name, metadata = {})
            put(name, Metadata.to_meta(metadata))
         end
      end
   end
end

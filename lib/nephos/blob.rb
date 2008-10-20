module Nephos
   class Blob < BaseObject

      class << self
         def store(container_name, blob_name, content)
            Container.validate_name container_name
            put(blob_path(container_name, blob_name), {}, content)
         end

         def blob_path(container_name, blob_name)
            "#{container_name}/#{URI.escape(blob_name)}"
         end

      end
   end
end

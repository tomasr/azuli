module Nephos
   class Parser
      def self.get(xml)
         options = {
            'ForceArray' => false
         }
         XmlSimple.xml_in(xml, options)
      end
   end
end

module Nokogiri
  module XML
    class EntityReference < Node

      def self.new(doc, name, &block)
        ptr = LibXML.xmlNewReference(doc.cstruct, name)
        node = Node.wrap(ptr)
        block.call(node) if block
        node
      end

    end
  end
end


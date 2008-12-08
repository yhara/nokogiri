module Nokogiri
  module XML
    class CDATA
      
      def self.new(document, content, &block)
        node_ptr = LibXML.xmlNewCDataBlock(document.cstruct, content, content.length)
        node = Node.wrap(node_ptr)
        if block_given?
          yield node
        end
        node
      end

    end
  end
end

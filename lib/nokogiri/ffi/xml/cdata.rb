module Nokogiri
  module XML
    class CDATA < Text
      
      def self.new(document, content, &block)
        length = content.nil? ? 0 : content.length
        node_ptr = LibXML.xmlNewCDataBlock(document.cstruct, content, length)
        node = Node.wrap(node_ptr)
        if block_given?
          yield node
        end
        node
      end

    end
  end
end

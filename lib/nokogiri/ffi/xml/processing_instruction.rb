module Nokogiri
  module XML
    class ProcessingInstruction < Node

      attr_accessor :cstruct

      def self.new(doc, name, content)
        node_ptr = LibXML.xmlNewDocPI(doc.cstruct, name.to_s, content.to_s)
        node = Node.wrap(node_ptr)
        yield node if block_given?
        node
      end

    end
  end
end

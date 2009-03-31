module Nokogiri
  module XML
    class DocumentFragment < Node

      def self.new(document, &block)
        node_cstruct = LibXML.xmlNewDocFragment(document.cstruct)
        node = Node.wrap(node_cstruct)
        
        node.cstruct[:ns] = node.document.child.cstruct[:ns] if node.document.child

        yield(node) if block_given?

        node
      end

    end
  end
end


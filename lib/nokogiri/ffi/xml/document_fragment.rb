module Nokogiri
  module XML
    class DocumentFragment < Node

      def self.new(document, &block)
        node_cstruct = LibXML.xmlNewDocFragment(document.cstruct)
        node = Node.wrap(node_cstruct)
        
        if node.document.child && node.document.child.node_type == ELEMENT_NODE
          # TODO: node_type check should be ported into master, because of e.g. DTD nodes
          node.cstruct[:ns] = node.document.children.first.cstruct[:ns] 
        end

        yield(node) if block_given?

        node
      end

    end
  end
end


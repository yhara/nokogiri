module Nokogiri
  module XML
    class Node

      attr_accessor :cstruct

      def self.new(name, document, &block)
        ptr = LibXML::xmlNewNode(nil, name)

        node_struct = LibXML::XmlNode.new(ptr)
        node_struct[:doc] = document.cstruct
        self.wrap(node_struct)

        yield node if block_given

        node
      end

      def self.wrap(node_struct)
        doc = LibXML::XmlDocumentCast.new(node_struct[:doc]).private
        node = doc.node_cache[node_struct.pointer.address]
        return node if node

        klass = case node_struct[:type]
                when TEXT_NODE then XML::Text
                when COMMENT_NODE then XML::Comment
                when ELEMENT_NODE then XML::Element
                when ENTITY_DECL then XML::EntityDeclaration
                when CDATA_SECTION_NODE then XML::CDATA
                when DTD_NODE then XML::DTD
                else XML::Node
                end
        node = klass.allocate
        node.cstruct = node_struct
        doc.node_cache[node_struct.pointer.address] = node
        node.document = doc
        node.decorate!
        node
      end

      def type
        cstruct[:type]
      end

    end
  end
end

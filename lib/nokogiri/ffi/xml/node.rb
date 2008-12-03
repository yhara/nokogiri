module Nokogiri
  module XML
    class Node

      attr_accessor :cstruct

      def self.new(name, document, &block)
        ptr = LibXML::xmlNewNode(nil, name)

        node_struct = LibXML::XmlNode.new(ptr)
        node_struct[:doc] = document.cstruct
        node = self.wrap(node_struct)

        yield node if block_given?

        node
      end

      #  accepts either a 
      def self.wrap(node_struct) # :nodoc:
        node_struct = LibXML::XmlNode.new(node_struct) if node_struct.is_a?(FFI::Pointer)
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

      def to_xml
        buffer = LibXML::XmlBuffer.new(LibXML.xmlBufferCreate())
        LibXML.xmlNodeDump(buffer, cstruct[:doc], cstruct, 2, 1)
        buffer[:content]
      end

      def name
        cstruct[:name].read_string
      end

      def child
        return nil if cstruct[:children].null?
        return XML::Node.wrap(cstruct[:children])
      end

      def encode_special_chars(string)
        char_ptr = LibXML.xmlEncodeSpecialChars(self[:doc], string)
        encoded = char_ptr.read_string
        LibXML.xmlFree(char_ptr)
        encoded
      end

      def key?(attribute)
        prop = LibXML.xmlHasProp(cstruct, attribute.to_s)
        prop.null? ? false : true
      end

      def native_content=(content)
        LibXML.xmlNodeSetContent(cstruct, content)
      end

      def content
        content_ptr = LibXML.xmlNodeGetContent(cstruct)
        return nil if content_ptr.null?
        content = content_ptr.read_string
        LibXML.xmlFree(content_ptr)
        content
      end

    end
  end
end

module Nokogiri
  module XML
    class Node

      attr_accessor :cstruct

      def self.new(name, document, &block)
        ptr = LibXML.xmlNewNode(nil, name.to_s)

        node_struct = LibXML::XmlNode.new(ptr)
        node_struct[:doc] = document.cstruct
        node = Node.wrap(node_struct)

        yield node if block_given?

        node
      end

      def self.new_from_str(xml)
        doc = XML::Document.read_memory(xml, nil, nil, 0)
        node_cstruct = LibXML.xmlCopyNode(LibXML.xmlDocGetRootElement(doc.cstruct), 1)
        node = LibXML::XmlNode.new(node_cstruct)
        node[:doc] = doc.cstruct
        Node.wrap(node)
      end

      #  accepts either a 
      def self.wrap(node_struct) # :nodoc:
        if node_struct.is_a?(FFI::Pointer)
          return nil if node_struct.null?
          node_struct = LibXML::XmlNode.new(node_struct) 
        end
        doc = LibXML::XmlDocumentCast.new(node_struct[:doc]).private
        node = doc.node_cache[node_struct.pointer.address] if doc
        return node if node

        klasses = case node_struct[:type]
                  when TEXT_NODE then [XML::Text]
                  when COMMENT_NODE then [XML::Comment]
                  when ELEMENT_NODE then [XML::Element]
                  when ENTITY_DECL then [XML::EntityDeclaration]
                  when CDATA_SECTION_NODE then [XML::CDATA]
                  when DTD_NODE then [XML::DTD, LibXML::XmlDtd]
                  else [XML::Node]
                  end
        node = klasses.first.allocate
        node.cstruct = klasses[1] ? klasses[1].new(node_struct.pointer) : node_struct
        doc.node_cache[node_struct.pointer.address] = node if doc
        node.document = doc
        node.decorate!
        node
      end

      def type
        cstruct[:type]
      end

      def to_xml(level = 1)
        buffer = LibXML::XmlBuffer.new(LibXML.xmlBufferCreate())
        LibXML.xmlNodeDump(buffer, cstruct[:doc], cstruct, 2, level)
        buffer[:content]
      end

      def name
        cstruct[:name]
      end

      def name=(string)
        LibXML.xmlNodeSetName(cstruct, string)
        string
      end

      def child
        val = cstruct[:children]
        val.null? ? nil : XML::Node.wrap(val)
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

      def get(attribute)
        prop_str = LibXML.xmlGetProp(cstruct, attribute.to_s)
        prop = prop_str.read_string
        LibXML.xmlFree(prop_str)
        prop
      end

      def []=(property, value)
        LibXML.xmlSetProp(cstruct, property, value)
        value
      end

      def parent
        val = cstruct[:parent]
        val.null? ? nil : Node.wrap(val)
      end
      
      def parent=(parent_node)
        LibXML.xmlAddChild(parent_node.cstruct, cstruct)
        parent_node
      end

      def internal_subset
        return nil if cstruct[:doc].null?
        doc = cstruct.document
        return nil if doc[:intSubset].null?
        Node.wrap(doc[:intSubset])
      end

      def blank?
        LibXML.xmlIsBlankNode(cstruct) == 1
      end

      def next_sibling
        val = cstruct[:next]
        val.null? ? nil : Node.wrap(val)
      end

      def previous_sibling
        val = cstruct[:prev]
        val.null? ? nil : Node.wrap(val)
      end

      def add_next_sibling new_sibling
        LibXML.xmlAddNextSibling(cstruct, new_sibling.cstruct)
        new_sibling.decorate!
        new_sibling
      end

      def add_previous_sibling new_sibling
        LibXML.xmlAddPrevSibling(cstruct, new_sibling.cstruct)
        new_sibling.decorate!
        new_sibling
      end

      def attributes
        ahash = {}
        prop = cstruct[:properties]
        while ! prop.null?
          prop_cstruct = LibXML::XmlAttr.new(prop)
          name = prop_cstruct[:name]
          prop_str = LibXML.xmlGetProp(cstruct, name)
          ahash[name] = prop_str.read_string unless prop_str.null?
          prop = prop_cstruct[:next]
        end
        ahash
      end

      def remove_attribute(prop)
        prop_ptr = LibXML.xmlHasProp(cstruct, prop)
        LibXML.xmlRemoveProp(prop_ptr) unless prop_ptr.null?
      end

      def namespaces
        ahash = {}
        return ahash unless cstruct[:type] == ELEMENT_NODE
        ns = cstruct[:nsDef]
        while ! ns.null?
          ns_cstruct = LibXML::XmlNs.new(ns)
          prefix = ns_cstruct[:prefix]
          key = if prefix.nil? || prefix.empty?
                  "xmlns"
                else
                  "xmlns:#{prefix}"
                end
          ahash[key] = ns_cstruct[:href]
          ns = ns_cstruct[:next]
        end
        ahash
      end

      def path
        path_ptr = LibXML.xmlGetNodePath(cstruct)
        val = path_ptr.null? ? nil : path_ptr.read_string
        LibXML.xmlFree(path_ptr)
        val
      end

      def replace_with_node(new_node)
        LibXML.xmlReplaceNode(cstruct, new_node.cstruct)
        self
      end

      def unlink
        LibXML.xmlUnlinkNode(cstruct)
        self
      end

    end
  end
end

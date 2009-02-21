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
                  when ATTRIBUTE_NODE then [XML::Attr]
                  when DOCUMENT_FRAG_NODE then [XML::DocumentFragment]
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
      alias_method :node_type, :type

      def to_html
        return to_xml if type == DOCUMENT_NODE
        buffer = LibXML::XmlBuffer.new(LibXML.xmlBufferCreate())
        LibXML.htmlNodeDump(buffer, cstruct[:doc], cstruct)
        buffer[:content]
      end

      def to_xml(level = 1)
        buffer = LibXML::XmlBuffer.new(LibXML.xmlBufferCreate())
        LibXML.xmlNodeDump(buffer, cstruct[:doc], cstruct, 2, level)
        buffer[:content]
      end

      def name
        cstruct[:name]
      end
      alias_method :node_name, :name

      def name=(string)
        LibXML.xmlNodeSetName(cstruct, string)
        string
      end
      alias_method :node_name=, :name=

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
        buffer = LibXML.xmlEncodeEntitiesReentrant(cstruct[:doc], value)
        LibXML.xmlSetProp(cstruct, property, buffer)
        value
      end

      def parent
        val = cstruct[:parent]
        val.null? ? nil : Node.wrap(val)
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

      def attribute_nodes
        prop_array = []
        prop_cstruct = cstruct[:properties]
        while ! prop_cstruct.null?
          prop = Node.wrap(prop_cstruct)
          prop_array << prop
          prop_cstruct = prop.cstruct[:next]
        end
        prop_array
      end

      def remove_attribute(prop)
        prop_ptr = LibXML.xmlHasProp(cstruct, prop)
        LibXML.xmlRemoveProp(prop_ptr) unless prop_ptr.null?
      end
      alias_method :delete, :remove_attribute

      def namespace
        return nil if cstruct[:ns].null?

        prefix = LibXML::XmlNs.new(cstruct[:ns])[:prefix]
        return prefix if prefix

        nil
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

      def add_child(child)
        LibXML.xmlUnlinkNode(child.cstruct)

        new_child_struct = LibXML.xmlAddChild(cstruct, child.cstruct)
        raise(RuntimeError, "Could not add new child") if new_child_struct.null?

        new_child = Node.wrap(new_child_struct)

        # the child was a text node that was coalesced. we need to have the object
        # point at SOMETHING, or we'll totally bomb out.
        if new_child_struct != child.cstruct.pointer
          child.cstruct = new_child.cstruct
        end

        child.decorate!
        child
      end

      def add_next_sibling(next_sibling)
        LibXML.xmlUnlinkNode(next_sibling.cstruct)

        new_next_sibling_struct = LibXML.xmlAddNextSibling(cstruct, next_sibling.cstruct)
        raise(RuntimeError, "Could not add next sibling") if new_next_sibling_struct.null?

        new_next_sibling = Node.wrap(new_next_sibling_struct)

        # the next_sibling was a text node that was coalesced. we need to have the object
        # point at SOMETHING, or we'll totally bomb out.
        if new_next_sibling_struct != next_sibling.cstruct.pointer
          next_sibling.cstruct = new_next_sibling.cstruct
        end

        next_sibling.decorate!
        next_sibling
      end

      def add_previous_sibling(prev_sibling)
        LibXML.xmlUnlinkNode(prev_sibling.cstruct)

        new_prev_sibling_struct = LibXML.xmlAddPrevSibling(cstruct, prev_sibling.cstruct)
        raise(RuntimeError, "Could not add previous sibling") if new_prev_sibling_struct.null?

        new_prev_sibling = Node.wrap(new_prev_sibling_struct)

        # the prev_sibling was a text node that was coalesced. we need to have the object
        # point at SOMETHING, or we'll totally bomb out.
        if new_prev_sibling_struct != prev_sibling.cstruct.pointer
          prev_sibling.cstruct = new_prev_sibling.cstruct
        end

        prev_sibling.decorate!
        prev_sibling
      end

      def dup(deep = 1)
        dup_ptr = LibXML.xmlCopyNode(cstruct, deep)
        return nil if dup_ptr.null?

        dup_cstruct = LibXML::XmlNode.new(dup_ptr)
        dup_cstruct[:doc] = cstruct[:doc]
        LibXML.xmlAddChild(dup_cstruct[:parent], dup_cstruct)

        Node.wrap(dup_cstruct)
      end

    end
  end
end

module Nokogiri
  module XML
    class Reader
      
      attr_accessor :cstruct

      def self.from_memory(buffer, url=nil, encoding=nil, options=0)
        reader_ptr = LibXML.xmlReaderForMemory(buffer, buffer.length, url, encoding, options)
        raise(RuntimeError, "couldn't create a reader") if reader_ptr.null?

        reader = allocate
        reader.cstruct = LibXML::XmlTextReader.new(reader_ptr)
        reader
      end

      def attribute name
        return nil if name.nil?
        attr_ptr = LibXML.xmlTextReaderGetAttribute(cstruct, name)
        if attr_ptr.null?
          # this section is an attempt to workaround older versions of libxml that
          # don't handle namespaces properly in all attribute-and-friends functions
          prefix = FFI::MemoryPointer.new :pointer
          localname = LibXML.xmlSplitQName2(name, prefix)
          if localname.null?
            attr_ptr = LibXML.xmlTextReaderLookupNamespace(cstruct, localname)
            LibXML.xmlFree(localname)
          else
            attr_ptr = LibXML.xmlTextReaderLookupNamespace(cstruct, prefix)
          end
          LibXML.xmlFree(prefix)
        end
        return nil if attr_ptr.null?

        attr = attr_ptr.read_string
        LibXML.xmlFree(attr_ptr)
        attr
      end

      def read
        ret = LibXML.xmlTextReaderRead(cstruct)
        return self if ret == 1
        return nil if ret == 0
        raise RuntimeError, "Error pulling: #{ret}"
      end

      def attribute_at index
        return nil if index.nil?
        index = index.to_i
        attr_ptr = LibXML.xmlTextReaderGetAttributeNo(cstruct, index)
        return nil if attr_ptr.null?

        attr = attr_ptr.read_string
        LibXML.xmlFree attr_ptr
        attr
      end

      def attribute_count
        count = LibXML.xmlTextReaderAttributeCount(cstruct)
        count == -1 ? nil : count
      end

      def attributes
        ahash = {}
        return ahash if ! attributes?
        node_ptr = LibXML.xmlTextReaderExpand(cstruct)
        return nil if node_ptr.null?

        node = Node.wrap(node_ptr)
        ahash.merge!(node.namespaces)
        ahash.merge!(node.attributes)
        ahash
      end

      def attributes? # :nodoc:
        #  this implementation of xmlTextReaderHasAttributes explicitly includes
        #  namespaces and properties, because some earlier versions ignore
        #  namespaces.
        node_ptr = LibXML.xmlTextReaderCurrentNode(cstruct)
        return false if node_ptr.null?
        node = LibXML::XmlNode.new node_ptr
        return true if node[:type] == Node::ELEMENT_NODE && (!node[:properties].null? || !node[:nsDef].null?)
        return false
      end

      def default?
        LibXML.xmlTextReaderIsDefault(cstruct) == 1
      end

      def depth
        val = LibXML.xmlTextReaderDepth(cstruct)
        val == -1 ? nil : val
      end

      def encoding
        val = LibXML.xmlTextReaderConstEncoding(cstruct)
        val.null? ? nil : val.read_string
      end

      def lang
        val = LibXML.xmlTextReaderConstXmlLang(cstruct)
        val.null? ? nil : val.read_string
      end

      def local_name
        val = LibXML.xmlTextReaderConstLocalName(cstruct)
        val.null? ? nil : val.read_string
      end

      def name
        val = LibXML.xmlTextReaderConstName(cstruct)
        val.null? ? nil : val.read_string
      end

      def namespace_uri
        val = LibXML.xmlTextReaderConstNamespaceUri(cstruct)
        val.null? ? nil : val.read_string
      end

      def prefix
        val = LibXML.xmlTextReaderConstPrefix(cstruct)
        val.null? ? nil : val.read_string
      end

      def value
        val = LibXML.xmlTextReaderConstValue(cstruct)
        val.null? ? nil : val.read_string
      end

      def value?
        LibXML.xmlTextReaderHasValue(cstruct) == 1
      end

      def state
        LibXML.xmlTextReaderReadState(cstruct)
      end

      def xml_version
        val = LibXML.xmlTextReaderConstXmlVersion(cstruct)
        val.null? ? nil : val.read_string
      end

    end
  end
end

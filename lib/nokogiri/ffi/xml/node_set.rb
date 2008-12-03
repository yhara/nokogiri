module Nokogiri
  module XML
    class NodeSet

      attr_accessor :cstruct

      def self.new document
        set = allocate
        set.document = document
        set.cstruct = LibXML::XmlNodeSet.new(LibXML.xmlXPathNodeSetCreate(nil))
        yield set if block_given?
        set
      end

      def length
        return 0 if cstruct.pointer.null?
        return cstruct[:nodeNr]
      end

      def [] number
        return nil if cstruct.pointer.null?
        return nil if (number >= cstruct[:nodeNr] || number.abs > cstruct[:nodeNr])
        number = number + cstruct[:nodeNr] if number < 0
        Node.wrap(cstruct.nodeTab[number])
      end

      def push(node)
        LibXML::xmlXPathNodeSetAdd(cstruct, node.cstruct)
        self
      end

    end
  end
end

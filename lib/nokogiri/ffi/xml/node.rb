module Nokogiri
  module XML
    class Node

      attr_accessor :cstruct

      def self.new(name, document, &block)
        ptr = LibXML::xmlNewNode(nil, name)

        node = allocate
        node.cstruct = LibXML::XmlNode.new(ptr) # TODO: Node#wrap
        node.cstruct[:doc] = document
        yield node if block_given
        node
      end

      def type
        cstruct[:type]
      end

    end
  end
end

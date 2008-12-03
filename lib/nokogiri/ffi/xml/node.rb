module Nokogiri
  module XML
    class Node

      attr_accessor :cstruct

      def self.new(name, document, &block)
        node = allocate
        node.cstruct = LibXML::XmlNode.new(LibXML::xmlNewNode(nil, name))
        node.cstruct[:doc] = document
        if block_given
          yield node
        end
        node
      end

      def type
        cstruct[:type]
      end

    end
  end
end

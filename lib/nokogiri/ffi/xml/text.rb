module Nokogiri
  module XML
    class Text < Node

      def self.new(string, document)
        node_cstruct = LibXML.xmlNewText(string)
        node = LibXML::XmlNode.new(node_cstruct)
        node[:doc] = document.cstruct
        rb_node = Node.wrap(node)
        if block_given?
          yield rb_node
        end
        rb_node
      end

    end
  end
end

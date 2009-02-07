module Nokogiri
  module XML
    class DocumentFragment

      def self.new(document, &block)
        node_cstruct = LibXML.xmlNewDocFragment(document.cstruct)
        node = Node.wrap(node_cstruct)
        yield(node) if block_given?
        node
      end

    end
  end
end


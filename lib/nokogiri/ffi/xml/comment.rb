module Nokogiri
  module XML
    class Comment
      
      def self.new(document, content, &block)
        node_ptr = LibXML.xmlNewDocComment(document.cstruct, content)
        node = Node.wrap(node_ptr)
        if block_given?
          yield node
        end
        node
      end

    end
  end
end

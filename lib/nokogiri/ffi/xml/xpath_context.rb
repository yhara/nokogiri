module Nokogiri
  module XML
    class XPathContext
      
      attr_accessor :cstruct

      def self.new(node)
        obj = allocate
        LibXML.xmlXPathInit()
        obj.cstruct = LibXML::XmlXpathContext.new(LibXML.xmlXPathNewContext(node.cstruct[:doc]))
        obj.cstruct[:node] = node.cstruct
        obj
      end

      def evaluate(search_path)
        xpath = XML::XPath.new
        xpath.cstruct = LibXML::XmlXpath.new(LibXML::xmlXPathEvalExpression(search_path, cstruct))
        if xpath.cstruct.pointer.null?
          raise XPath::SyntaxError, "Couldn't evaluate expression '#{search_path}'"
        end
        xpath.document = LibXML::XmlNode.new(cstruct[:node])[:doc]
        xpath
      end

    end
  end
end

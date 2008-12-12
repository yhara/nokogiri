module Nokogiri
  module XML
    class XPathContext
      
      attr_accessor :cstruct

      def self.new(node)
        LibXML.xmlXPathInit()

        ptr = LibXML.xmlXPathNewContext(node.cstruct[:doc])

        ctx = allocate
        ctx.cstruct = LibXML::XmlXpathContext.new(ptr)
        ctx.cstruct[:node] = node.cstruct
        ctx
      end

      def evaluate(search_path, xpath_handler = nil)
        ptr = LibXML.xmlXPathEvalExpression(search_path, cstruct)
        raise(XPath::SyntaxError, "Couldn't evaluate expression '#{search_path}'") if ptr.null?

        xpath = XML::XPath.new
        xpath.cstruct = LibXML::XmlXpath.new(ptr)
        xpath.document = cstruct.node.document.private
        xpath
      end

      def register_ns(prefix, uri)
        LibXML.xmlXPathRegisterNs(cstruct, prefix, uri)
      end

    end
  end
end

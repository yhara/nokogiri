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

      def evaluate(search_path, xpath_handler=nil)
        if xpath_handler
          raise "xpath evaluation with custom handlers not implemented"
#           lookup = lambda do |ctx, name, uri|
#             puts "MIKE: searching for '#{name}'"
#             nil
#           end
#           LibXML.xmlXPathRegisterFuncLookup(cstruct, lookup, nil);
        end

        LibXML.xmlResetLastError()
        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(nil))

        ptr = LibXML.xmlXPathEvalExpression(search_path, cstruct)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)

        if ptr.null?
          error = LibXML.xmlGetLastError()
          raise SyntaxError.wrap(error)
        end

        xpath = XML::XPath.new
        xpath.cstruct = LibXML::XmlXpath.new(ptr)
        xpath.document = cstruct[:doc]
        xpath
      end

      def register_ns(prefix, uri)
        LibXML.xmlXPathRegisterNs(cstruct, prefix, uri)
      end

    end
  end
end

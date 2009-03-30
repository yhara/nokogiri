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
        lookup = nil # to keep lambda in scope long enough to avoid a possible GC tragedy

        if xpath_handler
          lookup = lambda do |ctx, name, uri|
            return nil unless xpath_handler.respond_to?(name)
            ruby_funcall name, xpath_handler
          end
          LibXML.xmlXPathRegisterFuncLookup(cstruct, lookup, nil);
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

      private

      #
      #  returns a lambda that will call the handler function with marshalled parameters
      #
      def ruby_funcall(name, xpath_handler)
        lambda do |ctx, nargs|
          parser_context = LibXML::XmlXpathParserContext.new(ctx)
          context = parser_context.context
          doc = context.doc.ruby_doc

          params = []

          nargs.times do |j|
            obj = LibXML::XmlXpathObject.new(LibXML.valuePop(ctx))
            case obj[:type]
            when LibXML::XmlXpathObject::XPATH_STRING
              params.unshift obj[:stringval]
            when LibXML::XmlXpathObject::XPATH_BOOLEAN
              params.unshift obj[:boolval] == 1
            when LibXML::XmlXpathObject::XPATH_NUMBER
              params.unshift obj[:floatval]
            when LibXML::XmlXpathObject::XPATH_NODESET
              params.unshift LibXML::XmlNodeSet.new(obj[:nodesetval])
            else
              params.unshift LibXML.xmlXPathCastToString(obj)
            end
            LibXML.xmlXPathFreeNodeSetList(obj)
          end

          result = xpath_handler.send(name, *params)

        end
      end

    end
  end
end

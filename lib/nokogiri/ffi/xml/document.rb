module Nokogiri
  module XML
    class Document < Node

      attr_accessor :cstruct

      def self.new(*args)
        version = args.first || "1.0"
        wrap(LibXML.xmlNewDoc(version))
      end

      def self.read_memory(string, url, encoding, options)
        wrap_with_error_handling(DOCUMENT_NODE) do
          LibXML.xmlReadMemory(string, string.length, url, encoding, options)
        end
      end

      def self.read_io(io, url, encoding, options)
        wrap_with_error_handling(DOCUMENT_NODE) do
          reader = lambda do |ctx, buffer, len|
            string = io.read(len)
            return 0 if string.nil?
            LibXML.memcpy(buffer, string, string.length)
            string.length
          end
          closer = lambda { |ctx| 0 } # coffee is for closers.
          
          LibXML.xmlReadIO(reader, closer, nil, url, encoding, options)
        end
      end

      def self.wrap(ptr, type=DOCUMENT_NODE) # :nodoc:
        if type == DOCUMENT_NODE
          doc = allocate
          doc.cstruct = LibXML::XmlDocument.new(ptr)
          doc.cstruct[:type] = DOCUMENT_NODE
        else
          doc = Nokogiri::HTML::Document.allocate
          doc.cstruct = LibXML::HtmlDocument.new(ptr)
          doc.cstruct[:type] = HTML_DOCUMENT_NODE
        end
        doc.cstruct.ruby_doc = doc
        doc.instance_eval { @decorators = nil }
        doc
      end

      def type
        cstruct[:type]
      end

      def root
        ptr = LibXML.xmlDocGetRootElement(cstruct)
        ptr.null? ? nil : Node.wrap(LibXML::XmlNode.new(ptr))
      end

      def root=(node)
        LibXML.xmlDocSetRootElement(cstruct, node.cstruct)
        node
      end

      def encoding
        cstruct[:encoding]
      end

      def url
        cstruct[:URL]
      end

      def dup(deep = 1)
        dup_ptr = LibXML.xmlCopyDoc(cstruct, deep)
        return nil if dup_ptr.null?
        Document.wrap(dup_ptr, self.cstruct[:type])
      end

      private
      
      def self.wrap_with_error_handling(type, &block)
        error_list = []
        LibXML.xmlInitParser()
        LibXML.xmlResetLastError()
        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(error_list))

        ptr = yield
        
        LibXML.xmlSetStructuredErrorFunc(nil, nil)

        if ptr.null?
          error = LibXML.xmlGetLastError()
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not parse document"
          end
        end

        document = wrap(ptr, type)
        document.errors = error_list
        return document
      end

    end
  end
end
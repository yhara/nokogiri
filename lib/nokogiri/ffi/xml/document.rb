module Nokogiri
  module XML
    class Document

      attr_accessor :cstruct

      def self.new(*args)
        version = args.first || "1.0"
        doc = allocate
        doc.cstruct = LibXML::XmlDocument.new(LibXML::xmlNewDoc(version))
        doc
      end

      def self.read_memory(string, url, encoding, options)
        ptr = LibXML.xmlReadMemory(string, string.length, url, encoding, options)
        raise(RuntimeError, "Couldn't create a document") if ptr.null?

        doc = allocate
        doc.cstruct = LibXML::HtmlDocument.new(ptr)
        doc
      end

      def serialize
        buf_ptr = MemoryPointer.new :pointer
        size = MemoryPointer.new :int
        LibXML.xmlDocDumpMemory(cstruct, buf_ptr, size)
        buf = Nokogiri::LibXML::XmlAlloc.new(buf_ptr.read_pointer)
        buf.pointer.read_string(size.read_int)
      end

      def type
        cstruct[:type]
      end

      def root
        LibXML::XmlNode.new(LibXML.xmlDocGetRootElement(cstruct))
      end

    end
  end
end

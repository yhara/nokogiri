module Nokogiri
  module XML
    class Document

      attr_accessor :cstruct

      def self.new(*args)
        version = args.first || "1.0"
        wrap(LibXML::xmlNewDoc(version))
      end

      def self.read_memory(string, url, encoding, options)
        ptr = LibXML.xmlReadMemory(string, string.length, url, encoding, options)
        raise(RuntimeError, "Couldn't create a document") if ptr.null?
        wrap(ptr)
      end

      def self.wrap(ptr) # :nodoc:
        doc = allocate
        doc.cstruct = LibXML::XmlDocument.new(ptr)
        doc.cstruct.private = doc
        doc.instance_eval { @decorators = nil }
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
        Node.wrap(LibXML::XmlNode.new(LibXML.xmlDocGetRootElement(cstruct)))
      end

    end
  end
end

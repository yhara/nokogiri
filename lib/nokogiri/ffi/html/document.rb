module Nokogiri
  module HTML
    class Document

      attr_accessor :cstruct

      def self.read_memory(string, url, encoding, options)
        obj = allocate
        obj.cstruct = LibXML::HtmlDocument.new(LibXML.htmlReadMemory(string, string.length, url, encoding, options))
        # TODO: nil check
        obj
      end

      def serialize
        buf_ref = MemoryPointer.new :pointer
        size = MemoryPointer.new :int
        LibXML.htmlDocDumpMemory(cstruct, buf_ref, size)
        buf = Nokogiri::LibXML::XmlAlloc.new(buf_ref.read_pointer)
        buf.pointer.read_string(size.read_int)
      end

      def type
        cstruct[:type]
      end

    end
  end
end

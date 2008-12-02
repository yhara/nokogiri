require 'nokogiri/ffi/libxml'

module Nokogiri
  module XML
    class Document

      attr_accessor :cstruct

      def self.new(*args)
        obj = allocate
        version = args.first || "1.0"
        obj.cstruct = LibXML::XmlDoc.new(LibXML::xmlNewDoc(version))
        obj
      end

      def self.read_memory(string, url, encoding, options)
        obj = allocate
        obj.cstruct = LibXML::XmlDoc.new(LibXML.xmlReadMemory(string, string.length, url, encoding, options))
        # TODO: nil check
        obj
      end

      def serialize
        buf_ref = MemoryPointer.new :pointer
        size = MemoryPointer.new :int
        LibXML.xmlDocDumpMemory(cstruct, buf_ref, size)
        buf = Nokogiri::LibXML::XmlAlloc.new(buf_ref.read_pointer)
        buf.pointer.read_string(size.read_int)
      end

      def type
        cstruct[:type]
      end

    end
  end
end

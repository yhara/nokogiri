require 'nokogiri/ffi/libxml'
require 'nokogiri/ffi/structs/xml_doc'
require 'nokogiri/ffi/structs/xml_alloc'

module Nokogiri
  module HTML
    class Document

      attr_accessor :cstruct

      def self.read_memory(string, url, encoding, options)
        obj = self.new
        obj.cstruct = LibXML::XmlDoc.new(LibXML.htmlReadMemory(string, string.length, url, encoding, options))
        # TODO: nil check
        obj
      end

      def self.serialize(doc)
        buf = LibXML::XmlAlloc.new
        size = MemoryPointer.new :int
        LibXML.htmlDocDumpMemory(doc.cstruct, buf, size)
        buf.pointer.read_pointer.read_string(size.read_int)
      end

    end
  end
end

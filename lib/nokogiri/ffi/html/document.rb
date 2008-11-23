require 'nokogiri/ffi/libxml'
require 'nokogiri/ffi/structs/xml_doc'

module Nokogiri
  module HTML
    class Document

      attr_accessor :cstruct

      def self.read_memory(string, url, encoding, options)
        puts "MIKE: new read_memory"
        obj = self.new
        obj.cstruct = LibXML::XmlDoc.new(LibXML.htmlReadMemory(string, string.length, url, encoding, options))
        obj
      end

      def self.serialize(doc)
        puts "MIKE: new serialize"
        mem = MemoryPointer.new :pointer
        size = MemoryPointer.new :int
        LibXML.htmlDocDumpMemory(doc.cstruct.pointer, mem, size)
        mem.read_pointer.read_string(size.read_int)
      end

    end
  end
end

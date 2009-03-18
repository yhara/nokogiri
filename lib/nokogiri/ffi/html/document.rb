module Nokogiri
  module HTML
    class Document < XML::Document

      attr_accessor :cstruct

      def self.read_memory(string, url, encoding, options)
        ptr = LibXML.htmlReadMemory(string, string.length, url, encoding, options)
        raise(RuntimeError, "Couldn't create a document") if ptr.null?
        wrap(ptr)
      end

      def type
        cstruct[:type]
      end

    end
  end
end

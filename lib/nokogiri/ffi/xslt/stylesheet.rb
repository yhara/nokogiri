module Nokogiri
  module XSLT
    class Stylesheet

      attr_accessor :cstruct

      def self.parse_stylesheet_doc document
        ss = LibXML.xsltParseStylesheetDoc(LibXML::xmlCopyDoc(document.cstruct, 1)) # 1 => recursive

        obj = allocate
        obj.cstruct = LibXML::XsltStylesheet.new(ss)
        obj
      end

      def serialize document
        buf_ptr = MemoryPointer.new :pointer
        buf_len = MemoryPointer.new :int
        LibXML.xsltSaveResultToString(buf_ptr, buf_len, document.cstruct, cstruct)
        buf = Nokogiri::LibXML::XmlAlloc.new(buf_ptr.read_pointer)
        buf.pointer.read_string(buf_len.read_int)
      end

      def apply_to document, params=[]
        param_arr = MemoryPointer.new(:pointer, params.length + 1)
        params.each_with_index do |param, j|
          param_arr[j].put_pointer(0, MemoryPointer.from_string(param))
        end
        param_arr[params.length].put_pointer(0,0)

        ptr = LibXML.xsltApplyStylesheet(cstruct, document.cstruct, param_arr)
        newdoc = XML::Document.wrap(ptr)
        self.serialize(newdoc)
      end

    end
  end
end

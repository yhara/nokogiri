module Nokogiri
  module XML
    module SAX
      class Parser
        
        attr_accessor :cstruct

        def self.new document
          parser = allocate
          parser.document = document
          parser.cstruct = LibXML::XmlSaxHandler.allocate
          parser.send(:setup_lambdas)
          parser
        end

        def parse_memory data
          LibXML.xmlSAXUserParseMemory(cstruct, nil, data, data.length)
          data
        end

        def native_parse_io io, encoding
          read_proc = lambda do |ctx, buffer, len|
            string = io.read(len)
            return 0 if string.nil?
            LibXML.memcpy(buffer, string, string.length)
            string.length
          end
          close_proc = lambda { |ctx| return 0 }
          
          thing = LibXML.xmlCreateIOParserCtxt(cstruct, nil, read_proc, close_proc, nil, encoding)
          LibXML.xmlParseDocument(thing)
          io
        end

        def native_parse_file data
          LibXML.xmlSAXUserParseFile(cstruct, nil, data)
        end

      private
        def setup_lambdas
          @closures = {} # we need to keep references to the closures to avoid GC
          
          @closures[:startDocument] = lambda { |_| @document.start_document }
          @closures[:endDocument] = lambda { |_| @document.end_document }
          @closures[:startElement] = lambda do |_, name, attrs_ptr|
                       # eww.
                       attrs = []
                       j = 0
                       while !attrs_ptr.null? and !(value = attrs_ptr.get_pointer(j * FFI::Pointer.size)).null?
                         attrs << value.read_string
                         j += 1
                       end
                       @document.start_element name, attrs
                     end
          @closures[:endElement] = lambda { |_, name| @document.end_element name }
          @closures[:characters] = lambda { |_, data, data_length| @document.characters data.slice(0,data_length) }
          @closures[:cdataBlock] = lambda { |_, data, data_length| @document.cdata_block data.slice(0,data_length) }
          @closures[:comment] = lambda { |_, data| @document.comment data }

          @closures.each { |k,v| cstruct[k] = v }
        end

      end
    end
  end
end

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

      private
        def setup_lambdas
          @lambdas = [] # we need to keep references to these lambdas to avoid GC
          @lambdas << (cstruct[:startDocument] = lambda { |_| @document.start_document })
          @lambdas << (cstruct[:endDocument] = lambda { |_| @document.end_document })
          @lambdas << (cstruct[:startElement] = lambda do |_, name, attrs_ptr|
                         # eww.
                         attrs = []
                         j = 0
                         while !attrs_ptr.null? and !(value = attrs_ptr.get_pointer(j * FFI::Pointer.size)).null?
                           attrs << value.read_string
                           j += 1
                         end
                         @document.start_element name, attrs
          end)
          @lambdas << (cstruct[:endElement] = lambda { |_, name| @document.end_element name })
          @lambdas << (cstruct[:characters] = lambda { |_, data, data_length| @document.characters data.slice(0,data_length) })
          @lambdas << (cstruct[:cdataBlock] = lambda { |_, data, data_length| @document.cdata_block data.slice(0,data_length) })
          @lambdas << (cstruct[:comment] = lambda { |_, data| @document.comment data })
        end

      end
    end
  end
end

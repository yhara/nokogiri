module Nokogiri
  module HTML
    module SAX
      class Parser
        
        def native_parse_file data, encoding
          # TODO: isn't it more interesting to return the doc tree than the data we passed in?
          docptr = LibXML.htmlSAXParseFile(data, encoding, cstruct, nil)
          LibXML.xmlFreeDoc docptr
          data
        end

        def native_parse_memory data, encoding
          # TODO: isn't it more interesting to return the doc tree than the data we passed in?
          docptr = LibXML.htmlSAXParseDoc(data, encoding, cstruct, nil)
          LibXML.xmlFreeDoc docptr
          data
        end

      end
    end
  end
end

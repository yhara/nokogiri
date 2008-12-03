module Nokogiri
  module XML
    class XPath
      
      attr_accessor :cstruct

      def node_set
        ptr = cstruct[:nodesetval] if cstruct[:nodesetval]
        ptr = LibXml.xmlXPathNodeSetCreate(nil) if ptr.null?

        set = XML::NodeSet.new(@document)
        set.cstruct = LibXML::XmlNodeSet.new(ptr)
        set.document = @document
        set
      end

    end
  end
end

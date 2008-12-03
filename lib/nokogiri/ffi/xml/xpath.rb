module Nokogiri
  module XML
    class XPath
      
      attr_accessor :cstruct

      def node_set
        set = XML::NodeSet.new(@document)
        set.cstruct = LibXML::XmlNodeSet.new(cstruct[:nodesetval]) if cstruct[:nodesetval]
        set.cstruct = LibXML::XmlNodeSet.new(LibXml.xmlXPathNodeSetCreate(nil)) if set.cstruct.nil?
        set
      end

    end
  end
end

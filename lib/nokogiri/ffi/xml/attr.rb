module Nokogiri
  module XML
    class Attr

      def value=(content)
        unless cstruct[:children].null?
          LibXML.xmlFreeNodeList(cstruct[:children])
        end
        cstruct[:children] = cstruct[:last] = nil
        return unless content

        buffer = LibXML.xmlEncodeEntitiesReentrant(cstruct[:doc], content)

        cstruct[:children] = LibXML.xmlStringGetNodeList(cstruct[:doc], buffer)
        child_cstruct = cstruct[:children]
        while ! child_cstruct.null?
          child = Node.wrap(child_cstruct)
          child.cstruct[:parent] = cstruct
          child.cstruct[:doc] = cstruct[:doc]
          cstruct[:last] = child.cstruct
          child_cstruct = child.cstruct[:next]
        end

        content
      end

    end
  end
end

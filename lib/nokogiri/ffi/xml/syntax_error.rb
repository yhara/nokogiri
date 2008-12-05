module Nokogiri
  module XML
    class SyntaxError

      attr_accessor :cstruct

      def domain
        cstruct[:domain]
      end

      def code
        cstruct[:code]
      end

      def message
        cstruct[:message].null? ? nil : cstruct[:message]
      end

      def level
        cstruct[:level]
      end

      def file
        cstruct[:file].null? ? nil : cstruct[:file]
      end

      def line
        cstruct[:line]
      end

      def str1
        cstruct[:str1].null? ? nil : cstruct[:str1]
      end

      def str2
        cstruct[:str].null? ? nil : cstruct[:str]
      end

      def str3
        cstruct[:str3].null? ? nil : cstruct[:str3]
      end

      def int1
        cstruct[:int1]
      end

      def column
        cstruct[:int2]
      end
      alias_method :int2, :column

    end
  end

  # the lambda needs to be permanently referenced to avoid being GC'd
  Nokogiri::ErrorHandlerWrapper = lambda do |context, error_ptr|
    error_struct = Nokogiri::LibXML::XmlSyntaxError.new(error_ptr)
    error = Nokogiri::XML::SyntaxError.new
    error.cstruct = error_struct
    Nokogiri.error_handler.call(error)
  end
  Nokogiri::LibXML.xmlSetStructuredErrorFunc(nil, Nokogiri::ErrorHandlerWrapper)

end

module Nokogiri
  module XML
    class SyntaxError < ::Nokogiri::SyntaxError

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

      class << self
        def error_array_pusher(array, error)
          array << SyntaxError.wrap(error)
        end

        def error_array_pusher_to_proc(array)
          Proc.new do |_ignored_, error|
            error_array_pusher(array, error)
          end
        end

        def wrap(error_ptr)
          error_struct = Nokogiri::LibXML::XmlSyntaxError.new(error_ptr)
          LibXML.xmlCopyError(error_ptr, error_struct)
          error = Nokogiri::XML::SyntaxError.new
          error.cstruct = error_struct
          error
        end
      end

    end
  end

end

module Nokogiri
  module XML
    ###
    # Nokogiri::XML::Reader parses an XML document similar to the way a cursor
    # would move.  The Reader is given an XML document, and yields nodes
    # to an each block.
    #
    # Here is an example of usage:
    #
    #   reader = Nokogiri::XML::Reader(<<-eoxml)
    #     <x xmlns:tenderlove='http://tenderlovemaking.com/'>
    #       <tenderlove:foo awesome='true'>snuggles!</tenderlove:foo>
    #     </x>
    #   eoxml
    #
    #   reader.each do |node|
    #
    #     # node is an instance of Nokogiri::XML::Reader
    #     puts node.name
    #
    #   end
    # 
    # Note that Nokogiri::XML::Reader#each can only be called once!!  Once
    # the cursor moves through the entire document, you must parse the
    # document again.  So make sure that you capture any information you
    # need during the first iteration.
    #
    # The Reader parser is good for when you need the speed of a SAX parser,
    # but do not want to write a Document handler.
    class Reader
      include Enumerable

      # A list of errors encountered while parsing
      attr_accessor :errors

      # The encoding for the document
      attr_reader :encoding

      def initialize url = nil, encoding = nil # :nodoc:
        @errors = []
        @encoding = encoding
      end
      private :initialize

      ###
      # Get a list of attributes for the current node.
      def attributes
        Hash[*(attribute_nodes.map { |node|
          [node.name, node.to_s]
        }.flatten)].merge(namespaces || {})
      end

      ###
      # Move the cursor through the document yielding each node to the block
      def each(&block)
        while node = self.read
          block.call(node)
        end
      end
    end
  end
end

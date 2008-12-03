
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "helper"))

class TestFFI
  class TestBasic < Nokogiri::TestCase

    if defined? FFI

      def setup
        @loop_count = 100
        @wiggle_room = 2
      end
      
      def test_serialize_and_GC_HTML_documents
        Nokogiri::LibXML::HtmlDocument.expects(:release).at_least(@loop_count - @wiggle_room)
        @loop_count.times do
          doc = Nokogiri::HTML::Document.read_memory(File.read(HTML_FILE), nil, nil, 2145)
          assert_equal 66734, doc.serialize.size
        end
        10.times { GC.start }
      end

      def test_serialize_and_GC_XML_documents
        Nokogiri::LibXML::XmlDocument.expects(:release).at_least(@loop_count - @wiggle_room)
        @loop_count.times do
          doc = Nokogiri::XML::Document.read_memory(File.read(XML_FILE), nil, nil, 2145)
          assert_equal 1953, doc.serialize.size
        end
        10.times { GC.start }
      end

      def test_document_root
        doc = Nokogiri::XML(File.read(XML_FILE))
        assert_equal Nokogiri::XML::Element, doc.root.class
      end

    end

  end
end

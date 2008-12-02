
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "helper"))

class TestFFI
  class TestBasic < Nokogiri::TestCase
    LOOP_COUNT = 100
    WIGGLE_ROOM = 2
    
    def test_basic
      Nokogiri::LibXML::XmlDoc.expects(:release).at_least(LOOP_COUNT - WIGGLE_ROOM)
      LOOP_COUNT.times do
        doc = Nokogiri::HTML::Document.read_memory(File.read(HTML_FILE), nil, nil, 2145)
        assert_equal 66734, doc.serialize.size
      end
      10.times { GC.start }
    end
  end
end

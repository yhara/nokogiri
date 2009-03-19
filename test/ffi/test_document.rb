require File.expand_path(File.join(File.dirname(__FILE__), "..", "helper"))

if defined?(Nokogiri::LibXML)

  class FFI::TestDocument < Nokogiri::TestCase

    def test_reflection
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      assert_equal doc, doc.cstruct.private
    end

    def test_reflection_set
      doc = Nokogiri::XML("<root><foo>foo</foo></root>")
      foo = "foobar"
      doc.cstruct.private = foo
      assert_equal foo, doc.cstruct.private
    end

  end

end


require "#{File.dirname(__FILE__)}/helper"

class CrossFFITest < Test::Unit::TestCase

  context "in ruby-ffi" do

    require "#{File.dirname(__FILE__)}/ffi_helper"

    should "use CrossFFI::Struct to build structs with custom gc_free behavior" do
      CrossFFI::Prim1CrossFFI.expects(:gc_free).at_least(28) # leave some wiggle room

      30.times do
        p1 = CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
        s = CrossFFI::Prim1CrossFFI.new(p1)
        assert s.is_a?(CrossFFI::Struct)
        assert_equal 1, s[:i]
        assert_fequal 2.2, s[:f]
        assert_fequal 3.3, s[:d]
        assert_equal "foobar", s[:c]
        assert_equal 0, s[:next].read_pointer.address
      end
      gc_everything

    end

  end

end

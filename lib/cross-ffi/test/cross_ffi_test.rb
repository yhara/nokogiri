
require "#{File.dirname(__FILE__)}/helper"

class CrossFFITest < Test::Unit::TestCase

  require "#{File.dirname(__FILE__)}/ffi_helper"

  context "in ruby-ffi" do

    setup do
      @p1 = CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
      @p2 = CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", @p1)
    end

    should "use FFI::ManagedStruct to build structs with custom release behavior" do
      loop_count = 30
      wiggle_room = 2

      CrossFFI::Prim1CrossFFI.expects(:release).at_least(loop_count - wiggle_room)

      loop_count.times do |j|
        s = CrossFFI::Prim1CrossFFI.new(@p1)
        assert s.is_a?(FFI::ManagedStruct)
        assert_equal 1, s[:i]
        assert_fequal 2.2, s[:f]
        assert_fequal 3.3, s[:d]
        assert_equal "foobar", s[:c]
        assert_equal 0, s[:next].read_pointer.address
      end
      gc_everything
    end

    should "be able to receive values back" do
      loop_count = 30
      wiggle_room = 2
      CrossFFI::Prim1CrossFFI.expects(:release).at_least(loop_count - wiggle_room)
      loop_count.times do

        p3 = MemoryPointer.new :pointer
        CrossFFI::Primitives.prim1_get_next(@p2, p3)
        s = CrossFFI::Prim1CrossFFI.new(p3.read_pointer)
        assert_equal @p1.address, p3.read_pointer.address
        assert_equal @p1.address, s.pointer.address

      end
      gc_everything
    end

  end

end

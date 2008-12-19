
require "#{File.dirname(__FILE__)}/helper"

class CrossFFITest < Test::Unit::TestCase

  require "#{File.dirname(__FILE__)}/ffi_helper"

  context "in ruby-ffi" do

    setup do
      @p1 = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
      @p2 = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", @p1)
      @loop_count = 30
      @wiggle_room = (RUBY_PLATFORM =~ /java/) ? (@loop_count - 5) : 2 # jruby is conservative
    end

    should "use FFI::ManagedStruct to build structs with custom release behavior" do

      TestFFI::Prim1Managed.expects(:release).at_least(@loop_count - @wiggle_room)

      @loop_count.times do |j|
        s = TestFFI::Prim1Managed.new(@p1)
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
      TestFFI::Prim1Managed.expects(:release).at_least(@loop_count - @wiggle_room)
      @loop_count.times do

        p3 = MemoryPointer.new :pointer
        TestFFI::Primitives.prim1_get_next(@p2, p3)
        s = TestFFI::Prim1Managed.new(p3.read_pointer)
        assert_equal @p1.address, p3.read_pointer.address
        assert_equal @p1, s.pointer

      end
      gc_everything
    end

  end

end

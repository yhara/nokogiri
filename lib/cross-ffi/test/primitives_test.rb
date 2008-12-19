
require "#{File.dirname(__FILE__)}/helper"

class ExampleFreeMethodWrapper
  def self.free_method(ptr)
  end
  def self.create_finalizer(klass, method)
    # we do this in a method to avoid dragging in the scope of the caller
    klass.method(method.to_sym).to_proc
  end
end

class PrimitivesTest < Test::Unit::TestCase

  context "in ruby-ffi" do

    require "#{File.dirname(__FILE__)}/ffi_helper"

    setup do
      @loop_count = 30
      @wiggle_room = (RUBY_PLATFORM =~ /java/) ? (@loop_count - 5) : 2 # jruby is conservative
    end

    should "have sensible default pointer value" do
      p = MemoryPointer.new :pointer
      assert_equal 0, p.read_pointer.address
      assert p.read_pointer.null?
    end

    should "be able to pass values and pointers" do
      p0 = FFI::MemoryPointer.new(:pointer)
      p = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", p0)
      assert_equal CrossFFI::Pointer, p.class

      s = TestFFI::Prim1Ordinary.new(p)
      assert_equal 1, s[:i]
      assert_fequal 2.2, s[:f]
      assert_fequal 3.3, s[:d]
      assert_equal "foobar", s[:c]
      assert_equal 0, s[:next].read_pointer.address

      s2 = TestFFI::Prim1Ordinary.new(TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", s))
      assert_equal s.pointer, s2[:next]
    end    

    should "be able to use AutoPointer to invoke a custom release method" do
      ExampleFreeMethodWrapper.expects(:free_method).at_least(@loop_count - @wiggle_room)

      @loop_count.times do
        p1 = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
        assert_equal CrossFFI::Pointer, p1.class

        free_proc = ExampleFreeMethodWrapper.create_finalizer(ExampleFreeMethodWrapper, :free_method)
        p2 = FFI::AutoPointer.new(p1, free_proc)

        s = TestFFI::Prim1Ordinary.new(p1)
        assert_equal 1, s[:i]
        assert_fequal 2.2, s[:f]
        assert_fequal 3.3, s[:d]
        assert_equal "foobar", s[:c]
        assert_equal 0, s[:next].read_pointer.address
      end
      gc_everything
    end

    context "when receiving pointer values as output parameters" do
      
      setup do
        @p1 = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
        @p2 = TestFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", @p1)
      end

      should "be able to receive values back" do
        p3 = MemoryPointer.new :pointer
        TestFFI::Primitives.prim1_get_next(@p2, p3)
        s = TestFFI::Prim1Ordinary.new(p3)
        assert_equal @p1.address, p3.read_pointer.address
        assert_equal @p1.address, s.pointer.read_pointer.address
      end

      should "be able to receive strings back" do
        str = TestFFI::Primitives.prim1_dup_string("hello world")
        assert_equal str, "hello world"
        TestFFI::Primitives.free(str)
      end

    end

  end
  
end

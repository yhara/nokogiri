
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

    should "be able to pass values and pointers" do
      p = CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
      assert_equal FFI::Pointer, p.class

      s = CrossFFI::Prim1Ordinary.new(p)
      assert_equal 1, s[:i]
      assert_fequal 2.2, s[:f]
      assert_fequal 3.3, s[:d]
      assert_equal "foobar", s[:c]
      assert_equal 0, s[:next].read_pointer.address

      s2 = CrossFFI::Prim1Ordinary.new(CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", s))
      assert_equal s.pointer, s2[:next]
    end    

    should "be able to use AutoPointer to invoke a custom release method" do
      ExampleFreeMethodWrapper.expects(:free_method).at_least(28) # allow some wiggle room

      30.times do
        p1 = CrossFFI::Primitives.prim1_create(1, 2.2, 3.3, "foobar", FFI::MemoryPointer.new(:pointer))
        assert_equal FFI::Pointer, p1.class

        free_proc = ExampleFreeMethodWrapper.create_finalizer(ExampleFreeMethodWrapper, :free_method)
        p2 = FFI::AutoPointer.new(p1, free_proc)

        s = CrossFFI::Prim1Ordinary.new(p1)
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

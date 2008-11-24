

if defined? Rubinius::VM
  
  puts "cross-ffi: initializing for rubinius"

  require '/home/mike/code/rubinius/kernel/platform/ffi'

  class Module
  
    def ffi_attach library, name, arg_types, ret_type
      self.class.attach_foreign ret_type, name, arg_types, :from => library
    end

  end

else # ruby-ffi
    
  puts "cross-ffi: initializing for ruby-ffi"

  gem 'ffi', '>=0.2.0'
  require 'ffi'

  # duck punch!
  module FFI
    class AutoPointer
      def self.new(ptr, proc=nil, &block)
        klass = self
        free_lambda = if block_given?
                        lambda { block.call(ptr) } # backward compatible, will leak
                      elsif proc and proc.is_a? Proc
                        proc # mmm, tasty. this is what we want to use.
                      else
                        lambda { klass.release(ptr) } # backward compatible, will also leak
                      end
        ap = self.__alloc(ptr)
        ObjectSpace.define_finalizer(ap, free_lambda)
        ap
      end
    end
  end

  module CrossFFI
    class Struct < FFI::Struct

      def initialize(pointer)
        if self.class.respond_to? :gc_free
          pointer = FFI::AutoPointer.new(pointer, self.class.finalizer)
        end
        super(pointer)
      end

      def self.finalizer
        # in a separate method to avoid including the object in the Proc's bound scope.
        self.method(:gc_free).to_proc
      end

    end
  end

  class Module

    extend FFI::Library

    def ffi_attach library, name, arg_types, ret_type
      self.class.ffi_lib library
      self.class.attach_function name, arg_types, ret_type
    end

  end

end

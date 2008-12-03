

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

  # duck punch! - this will be in ffi 0.2.0 and should be removed after that.
  module FFI
    class AutoPointer < Pointer

      # call-seq:
      #   AutoPointer.new(pointer, method)     => the passed Method will be invoked at GC time
      #   AutoPointer.new(pointer, proc)       => the passed Proc will be invoked at GC time (SEE WARNING BELOW!)
      #   AutoPointer.new(pointer) { |p| ... } => the passed block will be invoked at GC time (SEE WARNING BELOW!)
      #   AutoPointer.new(pointer)             => the pointer's release() class method will be invoked at GC time
      #
      # WARNING: passing a proc _may_ cuase your pointer to never be GC'd, unless you're careful to avoid trapping a reference to the pointer in the proc. See the test specs for examples.
      # WARNING: passing a block will cause your pointer to never be GC'd. This is bad.
      #
      # Please note that the safest, and therefore preferred, calling
      # idiom is to pass a Method as the second parameter. Example usage:
      #
      #   class PointerHelper
      #     def self.release(pointer)
      #       ...
      #     end
      #   end
      #
      #   p = AutoPointer.new(other_pointer, PointerHelper.method(:release))
      #
      # The above code will cause PointerHelper#release to be invoked at GC time.
      #
      # The last calling idiom (only one parameter) is generally only
      # going to be useful if you subclass AutoPointer, and override
      # release(), which by default does nothing.
      #
      def self.new(ptr, proc=nil)
        raise ArgumentError, "Invalid pointer" if ptr.nil? || !ptr.kind_of?(Pointer) \
          || ptr.kind_of?(MemoryPointer) || ptr.kind_of?(AutoPointer)
        free_lambda = if proc and proc.is_a? Method
                        finalize(ptr, self.method_to_proc(proc))
                      elsif proc and proc.is_a? Proc
                        finalize(ptr, proc)
                      else
                        finalize(ptr, self.method_to_proc(self.method(:release)))
                      end
        ap = self.__alloc(ptr)
        ObjectSpace.define_finalizer(ap, free_lambda)
        ap
      end
      def self.release(ptr)
      end

      private
      def self.finalize(ptr, proc)
        #
        #  having a method create the lambda eliminates inadvertent
        #  references to the underlying object, which would prevent GC
        #  from running.
        #
        Proc.new do |*args|
          begin
            proc.call(ptr)
          rescue
            warn "autopointer:finalize: caught exception '#{$!.to_s.chomp}'" if $DEBUG
            raise $!
          end
        end
      end
      def self.method_to_proc method
        #  again, can't call this inline as it causes a memory leak.
        method.to_proc
      end
    end
  end

  # this will be in ffi 0.2.0 and should be removed after that.
  module FFI
    class ManagedStruct < FFI::Struct

      def initialize(pointer=nil)
        raise NoMethodError, "release() not implemented for class #{self}" unless self.class.respond_to? :release
        raise ArgumentError, "Must supply a pointer to memory for the Struct" unless pointer
        super FFI::AutoPointer.new(pointer, self.class.method(:release))
      end

    end
  end

  class Module

    extend FFI::Library

    def ffi_attach library, name, arg_types, ret_type
      self.class.ffi_lib library
      self.class.attach_function name, arg_types, ret_type
    end

    def ffi_callback(*args)
      self.class.callback *args
    end

  end

  module CrossFFI

    class Struct < FFI::ManagedStruct
    end

  end

end

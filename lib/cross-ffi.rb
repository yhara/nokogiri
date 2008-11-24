

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

  module CrossFFI
    class Struct < FFI::Struct

      def initialize(pointer)
        if self.class.respond_to? :free
          pointer = FFI::AutoPointer.new(pointer) {|p| self.class.free(p)}
        end
        super(pointer)
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

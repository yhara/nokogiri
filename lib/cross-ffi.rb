

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

  gem 'ffi', '>=0.3.0'
  require 'ffi'

  module CrossFFI

    module ModuleMixin

      def self.extended(base)
        base.extend FFI::Library
      end
      
      def ffi_attach library, name, arg_types, ret_type
        self.ffi_lib library
        self.attach_function name, arg_types, ret_type
      end
      
      def ffi_callback(*args)
        self.callback(*args)
      end
      
    end

    class Struct < FFI::ManagedStruct
    end

  end

end

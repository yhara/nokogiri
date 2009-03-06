if defined? Rubinius::VM
  
  puts "cross-ffi: initializing for rubinius"

  require '/home/mike/code/rubinius/kernel/platform/ffi'

  class Module
  
    def ffi_attach library, name, arg_types, ret_type
      self.class.attach_foreign ret_type, name, arg_types, :from => library
    end

  end

else # ruby-ffi or jruby
    
  puts "cross-ffi: initializing for ruby-ffi"

  gem 'ffi', '>=0.3.0' unless RUBY_PLATFORM =~ /java/
  require 'ffi'

  module CrossFFI

    Pointer = FFI::Pointer

    module ModuleMixin

      def self.extended(base)
        base.extend FFI::Library
      end
      
      def ffi_attach library, name, arg_types, ret_type
        ffi_lib expand_library_path(library)
        attach_function name, arg_types, ret_type
      end
      
      def ffi_callback(*args)
        callback(*args)
      end

      private
      def expand_library_path library
        return File.expand_path(library) if library =~ %r{^[^/].*/}
        library ? "/usr/lib/#{library}.so" : nil # TODO: how to set jruby library load paths?
#        library # TODO WTF?
      end

    end

    class Struct < FFI::ManagedStruct
    end

  end

  module FFI
    class Pointer
      def write_pointer(ptr)
        put_pointer(0, ptr)
      end

      def read_array_of_pointer(length)
        read_array_of_type(:pointer, :read_pointer, length)
      end

      def write_array_of_pointer(ary)
        write_array_of_type(:pointer, :write_pointer, ary)
      end
    end
  end
end

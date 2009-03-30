

module CrossFFI

  module ModuleMixin

    def ffi_attach library, name, arg_types, ret_type
      ffi_lib expand_library_path(library)
      attach_function name, arg_types, ret_type
    end
    
    def ffi_callback(*args)
      callback(*args)
    end
  end

end

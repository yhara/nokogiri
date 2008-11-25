
require 'cross-ffi'

module Nokogiri
  module LibXML
    ffi_attach 'libxml2', :htmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :htmlDocDumpMemory, [:pointer, :pointer, :pointer], :void

    ffi_attach 'libxml2', :xmlNewDoc, [:string], :pointer
    ffi_attach 'libxml2', :xmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :xmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlDocGetRootElement, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlDocSetRootElement, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlSubstituteEntitiesDefault, [:int], :int

    ffi_attach 'libxml2', :xmlInitParser, [], :void
    ffi_attach 'libxml2', :xmlFreeDoc, [:pointer], :void

    # xmlFree is a C preprocessor macro, not an actual address.
    ffi_attach nil, :free, [:pointer], :void
    def self.xmlFree(pointer)
      self.free(pointer)
    end

  end
end

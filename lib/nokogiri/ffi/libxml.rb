
require 'cross-ffi'

module Nokogiri
  module LibXML
    ffi_attach 'libxml2', :htmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :htmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlFreeDoc, [:pointer], :void
  end
end

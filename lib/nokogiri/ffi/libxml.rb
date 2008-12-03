
require 'cross-ffi'

module Nokogiri
  module LibXML
    # html documents
    ffi_attach 'libxml2', :htmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :htmlDocDumpMemory, [:pointer, :pointer, :pointer], :void

    # xml documents
    ffi_attach 'libxml2', :xmlNewDoc, [:string], :pointer
    ffi_attach 'libxml2', :xmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :xmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlDocGetRootElement, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlDocSetRootElement, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlSubstituteEntitiesDefault, [:int], :int
    ffi_attach 'libxml2', :xmlFreeDoc, [:pointer], :void

    # nodes
    ffi_attach 'libxml2', :xmlNewNode, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlEncodeSpecialChars, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlCopyNode, [:pointer, :int], :pointer
    ffi_attach 'libxml2', :xmlReplaceNode, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlUnlinkNode, [:pointer], :void
    ffi_attach 'libxml2', :xmlAddChild, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlAddNextSibling, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlAddPrevSibling, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlIsBlankNode, [:pointer], :int
    ffi_attach 'libxml2', :xmlHasProp, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlGetProp, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlSetProp, [:pointer, :pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlRemoveProp, [:pointer], :int
    ffi_attach 'libxml2', :xmlNodeSetContent, [:pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlNodeGetContent, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlNodeSetName, [:pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlGetNodePath, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlNodeDump, [:pointer, :pointer, :pointer, :int, :int], :int

    # miscellaneous
    ffi_attach 'libxml2', :xmlInitParser, [], :void
    ffi_attach 'libxml2', :xmlBufferFree, [:pointer], :void

    # xpath
    ffi_attach 'libxml2', :xmlXPathInit, [], :void
    ffi_attach 'libxml2', :xmlXPathNewContext, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlXPathFreeContext, [:pointer], :void
    ffi_attach 'libxml2', :xmlXPathEvalExpression, [:pointer, :pointer], :pointer

    # xmlFree is a C preprocessor macro, not an actual address.
    ffi_attach nil, :free, [:pointer], :void
    def self.xmlFree(pointer)
      self.free(pointer)
    end

  end
end



[ "structs/xml_alloc",
  "structs/xml_document",
  "structs/xml_node",
  "structs/xml_node_set",
  "structs/xml_xpath_context",
  "structs/xml_xpath",
  "html/document.rb",
  "xml/document.rb",
  "xml/node.rb",
  "xml/node_set.rb",
  "xml/xpath.rb",
  "xml/xpath_context.rb" ].each do |file|
  require File.join(File.dirname(__FILE__), file)
end

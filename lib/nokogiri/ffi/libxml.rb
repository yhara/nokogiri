
require 'cross-ffi'

module Nokogiri
  module LibXML
    extend CrossFFI::ModuleMixin

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
    ffi_attach 'libxml2', :xmlCopyDoc, [:pointer, :int], :pointer
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
    ffi_attach 'libxml2', :xmlNewCDataBlock, [:pointer, :pointer, :int], :pointer
    ffi_attach 'libxml2', :xmlNewDocComment, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlNewText, [:pointer], :pointer

    # buffer
    ffi_attach 'libxml2', :xmlBufferCreate, [], :pointer
    ffi_attach 'libxml2', :xmlBufferFree, [:pointer], :void

    # miscellaneous
    ffi_attach 'libxml2', :xmlInitParser, [], :void
    ffi_attach 'libxml2', :__xmlParserVersion, [], :string
    ffi_attach 'libxml2', :xmlSplitQName2, [:string, :pointer], :pointer

    # xpath
    ffi_attach 'libxml2', :xmlXPathInit, [], :void
    ffi_attach 'libxml2', :xmlXPathNewContext, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlXPathFreeContext, [:pointer], :void
    ffi_attach 'libxml2', :xmlXPathEvalExpression, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlXPathRegisterNs, [:pointer, :pointer, :pointer], :int
    ffi_attach 'libxml2', :xmlXPathNodeSetAdd, [:pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlXPathNodeSetCreate, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlXPathFreeNodeSetList, [:pointer], :void

    # xmlFree is a C preprocessor macro, not an actual address.
    ffi_attach nil, :calloc, [:int, :int], :pointer
    ffi_attach nil, :free, [:pointer], :void
    def self.xmlFree(pointer)
      self.free(pointer)
    end

    # syntax error handler
    ffi_callback :syntax_error_handler, [:pointer, :pointer], :void
    ffi_attach 'libxml2', :xmlSetStructuredErrorFunc, [:pointer, :syntax_error_handler], :void

    # IO
    ffi_callback :io_read_callback, [:pointer, :pointer, :int], :int
    ffi_callback :io_close_callback, [:pointer], :int
    ffi_attach nil, :memcpy, [:pointer, :pointer, :int], :pointer
    ffi_attach 'libxml2', :xmlReadIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer

    # dtd
    ffi_callback :hash_copier_callback, [:pointer, :pointer, :string], :void
    ffi_attach 'libxml2', :xmlHashScan, [:pointer, :hash_copier_callback, :pointer], :void

    # reader
    ffi_attach 'libxml2', :xmlReaderForMemory, [:string, :int, :string, :string, :int], :pointer
    ffi_attach 'libxml2', :xmlTextReaderGetAttribute, [:pointer, :string], :pointer
    ffi_attach 'libxml2', :xmlTextReaderGetAttributeNo, [:pointer, :int], :pointer
    ffi_attach 'libxml2', :xmlTextReaderLookupNamespace, [:pointer, :pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderRead, [:pointer], :int
    ffi_attach 'libxml2', :xmlTextReaderAttributeCount, [:pointer], :int
    ffi_attach 'libxml2', :xmlTextReaderCurrentNode, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderExpand, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderIsDefault, [:pointer], :int
    ffi_attach 'libxml2', :xmlTextReaderDepth, [:pointer], :int
    ffi_attach 'libxml2', :xmlTextReaderConstEncoding, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstXmlLang, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstLocalName, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstName, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstNamespaceUri, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstPrefix, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstValue, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderConstXmlVersion, [:pointer], :pointer
    ffi_attach 'libxml2', :xmlTextReaderReadState, [:pointer], :int
    ffi_attach 'libxml2', :xmlTextReaderHasValue, [:pointer], :int
    ffi_attach 'libxml2', :xmlFreeTextReader, [:pointer], :void

    # xslt
    ffi_attach 'libxslt', :xsltParseStylesheetDoc, [:pointer], :pointer
    ffi_attach 'libxslt', :xsltFreeStylesheet, [:pointer], :void
    ffi_attach 'libxslt', :xsltApplyStylesheet, [:pointer, :pointer, :pointer], :pointer
    ffi_attach 'libxslt', :xsltSaveResultToString, [:pointer, :pointer, :pointer, :pointer], :void

    # sax
    ffi_callback :start_document_sax_func, [:pointer], :void
    ffi_callback :end_document_sax_func, [:pointer], :void
    ffi_callback :start_element_sax_func, [:pointer, :string, :pointer], :void
    ffi_callback :end_element_sax_func, [:pointer, :string], :void
    ffi_callback :characters_sax_func, [:pointer, :string, :int], :void
    ffi_callback :comment_sax_func, [:pointer, :string], :void
    ffi_callback :warning_sax_func, [:pointer, :string], :void
    ffi_callback :error_sax_func, [:pointer, :string], :void
    ffi_callback :cdata_block_sax_func, [:pointer, :string, :int], :void

    ffi_attach 'libxml2', :xmlSAXUserParseMemory, [:pointer, :pointer, :pointer, :int], :int
  end
end

Nokogiri::LIBXML_VERSION = Nokogiri::LibXML.__xmlParserVersion()

[ "structs/xml_alloc",
  "structs/xml_document",
  "structs/xml_node",
  "structs/xml_dtd",
  "structs/xml_notation",
  "structs/xml_node_set",
  "structs/xml_xpath_context",
  "structs/xml_xpath",
  "structs/xml_buffer",
  "structs/xml_syntax_error",
  "structs/xml_attr.rb",
  "structs/xml_ns.rb",
  "structs/xml_text_reader.rb",
  "structs/xml_sax_handler.rb",
  "structs/xslt_stylesheet.rb",
  "xml/document.rb",
  "xml/node.rb",
  "xml/text.rb",
  "xml/cdata.rb",
  "xml/dtd.rb",
  "xml/comment.rb",
  "xml/node_set.rb",
  "xml/xpath.rb",
  "xml/xpath_context.rb",
  "xml/syntax_error.rb",
  "xml/reader.rb",
  "xml/sax/parser.rb",
  "html/document.rb",
  "xslt/stylesheet.rb",
].each do |file|
  require File.join(File.dirname(__FILE__), file)
end

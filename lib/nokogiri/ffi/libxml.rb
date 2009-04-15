
require 'cross-ffi'

module Nokogiri
  module LibXML

    def self.expand_library_path(library)
      return File.expand_path(library) if library =~ %r{^[^/].*/}
      library = Dir[
        "/opt/local/lib/#{library}.{so,dylib}",
        "/usr/local/lib/#{library}.{so,dylib}",
        "/usr/lib/#{library}.{so,dylib}",
      ].first

      raise "Couldn't find #{library}" unless library

      library
    end

    extend FFI::Library
    ffi_lib expand_library_path('libxml2')
    ffi_lib expand_library_path('libxslt')
    ffi_lib expand_library_path('libexslt')

    # useful callback signatures
    callback :syntax_error_handler, [:pointer, :pointer], :void
    callback :generic_error_handler, [:pointer, :string], :void
    callback :io_write_callback, [:pointer, :string, :int], :int
    callback :io_read_callback, [:pointer, :pointer, :int], :int
    callback :io_close_callback, [:pointer], :int
    callback :hash_copier_callback, [:pointer, :pointer, :string], :void
    callback :xpath_callback, [:pointer, :int], :void
    callback :xpath_lookup_callback, [:pointer, :string, :pointer], :xpath_callback

    # html documents
    attach_function :htmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    attach_function :htmlReadIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer
    attach_function :htmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    attach_function :htmlNewDoc, [:string, :string], :pointer
    attach_function :htmlNodeDump, [:pointer, :pointer, :pointer], :int
    attach_function :htmlGetMetaEncoding, [:pointer, :pointer], :string
    attach_function :htmlSetMetaEncoding, [:pointer, :pointer], :void
    attach_function :htmlTagLookup, [:string], :pointer
    attach_function :htmlEntityLookup, [:string], :pointer

    # xml documents
    attach_function :xmlNewDoc, [:string], :pointer
    attach_function :xmlNewDocFragment, [:pointer], :pointer
    attach_function :xmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    attach_function :xmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    attach_function :xmlDocGetRootElement, [:pointer], :pointer
    attach_function :xmlDocSetRootElement, [:pointer, :pointer], :pointer
    attach_function :xmlSubstituteEntitiesDefault, [:int], :int
    attach_function :xmlCopyDoc, [:pointer, :int], :pointer
    attach_function :xmlFreeDoc, [:pointer], :void
    attach_function :xmlSetTreeDoc, [:pointer, :pointer], :void
    attach_function :xmlNewReference, [:pointer, :string], :pointer

    # nodes
    attach_function :xmlNewNode, [:pointer, :pointer], :pointer
    attach_function :xmlEncodeSpecialChars, [:pointer, :pointer], :pointer
    attach_function :xmlCopyNode, [:pointer, :int], :pointer
    attach_function :xmlDocCopyNode, [:pointer, :pointer, :int], :pointer
    attach_function :xmlReplaceNode, [:pointer, :pointer], :pointer
    attach_function :xmlUnlinkNode, [:pointer], :void
    attach_function :xmlAddChild, [:pointer, :pointer], :pointer
    attach_function :xmlAddNextSibling, [:pointer, :pointer], :pointer
    attach_function :xmlAddPrevSibling, [:pointer, :pointer], :pointer
    attach_function :xmlIsBlankNode, [:pointer], :int
    attach_function :xmlHasProp, [:pointer, :pointer], :pointer
    attach_function :xmlGetProp, [:pointer, :pointer], :pointer
    attach_function :xmlSetProp, [:pointer, :pointer, :pointer], :pointer
    attach_function :xmlRemoveProp, [:pointer], :int
    attach_function :xmlNodeSetContent, [:pointer, :pointer], :void
    attach_function :xmlNodeGetContent, [:pointer], :pointer
    attach_function :xmlNodeSetName, [:pointer, :pointer], :void
    attach_function :xmlGetNodePath, [:pointer], :pointer
    attach_function :xmlNodeDump, [:pointer, :pointer, :pointer, :int, :int], :int
    attach_function :xmlNewCDataBlock, [:pointer, :pointer, :int], :pointer
    attach_function :xmlNewDocComment, [:pointer, :pointer], :pointer
    attach_function :xmlNewText, [:pointer], :pointer
    attach_function :xmlFreeNode, [:pointer], :void
    attach_function :xmlFreeNodeList, [:pointer], :void
    attach_function :xmlEncodeEntitiesReentrant, [:pointer, :string], :string
    attach_function :xmlStringGetNodeList, [:pointer, :string], :pointer
    attach_function :xmlNewNs, [:pointer, :string, :string], :pointer
    attach_function :xmlNewNsProp, [:pointer, :pointer, :string, :string], :pointer
    attach_function :xmlSearchNsByHref, [:pointer, :pointer, :pointer], :pointer

    attach_function :xmlSaveToIO, [:io_write_callback, :io_close_callback, :pointer, :string, :int], :pointer
    attach_function :xmlSaveTree, [:pointer, :pointer], :int
    attach_function :xmlSaveClose, [:pointer], :int
    attach_function :xmlGetIntSubset, [:pointer], :pointer

    # buffer
    attach_function :xmlBufferCreate, [], :pointer
    attach_function :xmlBufferFree, [:pointer], :void

    # miscellaneous
    attach_function :xmlInitParser, [], :void
    attach_function :__xmlParserVersion, [], :pointer
    attach_function :xmlSplitQName2, [:string, :pointer], :pointer

    # xpath
    attach_function :xmlXPathInit, [], :void
    attach_function :xmlXPathNewContext, [:pointer], :pointer
    attach_function :xmlXPathFreeContext, [:pointer], :void
    attach_function :xmlXPathEvalExpression, [:string, :pointer], :pointer
    attach_function :xmlXPathRegisterNs, [:pointer, :pointer, :pointer], :int
    attach_function :xmlXPathCmpNodes, [:pointer, :pointer], :int
    attach_function :xmlXPathNodeSetAdd, [:pointer, :pointer], :void
    attach_function :xmlXPathNodeSetCreate, [:pointer], :pointer
    attach_function :xmlXPathFreeNodeSetList, [:pointer], :void
    attach_function :xmlXPathRegisterFuncLookup, [:pointer, :xpath_lookup_callback, :pointer], :xpath_callback
    attach_function :valuePop, [:pointer], :pointer
    attach_function :xmlXPathCastToString, [:pointer], :string
    attach_function :xmlXPathNodeSetMerge, [:pointer, :pointer], :pointer
    attach_function :valuePush, [:pointer, :pointer], :int
    attach_function :xmlXPathWrapNodeSet, [:pointer], :pointer
    attach_function :xmlXPathWrapCString, [:pointer], :pointer
    attach_function :xmlXPathWrapString, [:pointer], :pointer
    attach_function :xmlXPathNewBoolean, [:int], :pointer
    attach_function :xmlXPathNewFloat, [:double], :pointer
    class << self
      # these functions are implemented as C macros
      def xmlXPathReturnNodeSet(ctx, ns)
        valuePush(ctx, xmlXPathWrapNodeSet(ns))
      end
      def xmlXPathReturnTrue(ctx)
        valuePush(ctx, xmlXPathNewBoolean(1))
      end
      def xmlXPathReturnFalse(ctx)
        valuePush(ctx, xmlXPathNewBoolean(0))
      end
      def xmlXPathReturnString(ctx, str)
        valuePush(ctx, xmlXPathWrapString(str))
      end
      def xmlXPathReturnNumber(ctx, val)
        valuePush(ctx, xmlXPathNewFloat(val))
      end
    end

    attach_function :xmlStrdup, [:pointer], :pointer
    attach_function :calloc, [:int, :int], :pointer
    attach_function :free, [:pointer], :void
    attach_function :memcpy, [:pointer, :pointer, :int], :pointer
    def self.xmlFree(pointer)
      # xmlFree is a C preprocessor macro, not an actual address.
      self.free(pointer)
    end

    # syntax error handler
    attach_function :xmlSetStructuredErrorFunc, [:pointer, :syntax_error_handler], :void
    attach_function :xmlSetGenericErrorFunc, [:pointer, :generic_error_handler], :void
    attach_function :xmlResetLastError, [], :void
    attach_function :xmlCopyError, [:pointer, :pointer], :int
    attach_function :xmlGetLastError, [], :pointer

    # IO
    attach_function :xmlReadIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer
    attach_function :xmlCreateIOParserCtxt, [:pointer, :pointer, :io_read_callback, :io_close_callback, :pointer, :int], :pointer

    # dtd
    attach_function :xmlHashScan, [:pointer, :hash_copier_callback, :pointer], :void

    # reader
    attach_function :xmlReaderForMemory, [:pointer, :int, :string, :string, :int], :pointer
    attach_function :xmlTextReaderGetAttribute, [:pointer, :string], :pointer
    attach_function :xmlTextReaderGetAttributeNo, [:pointer, :int], :pointer
    attach_function :xmlTextReaderLookupNamespace, [:pointer, :pointer], :pointer
    attach_function :xmlTextReaderRead, [:pointer], :int
    attach_function :xmlTextReaderAttributeCount, [:pointer], :int
    attach_function :xmlTextReaderCurrentNode, [:pointer], :pointer
    attach_function :xmlTextReaderExpand, [:pointer], :pointer
    attach_function :xmlTextReaderIsDefault, [:pointer], :int
    attach_function :xmlTextReaderDepth, [:pointer], :int
    attach_function :xmlTextReaderConstEncoding, [:pointer], :pointer
    attach_function :xmlTextReaderConstXmlLang, [:pointer], :pointer
    attach_function :xmlTextReaderConstLocalName, [:pointer], :pointer
    attach_function :xmlTextReaderConstName, [:pointer], :pointer
    attach_function :xmlTextReaderConstNamespaceUri, [:pointer], :pointer
    attach_function :xmlTextReaderConstPrefix, [:pointer], :pointer
    attach_function :xmlTextReaderConstValue, [:pointer], :pointer
    attach_function :xmlTextReaderConstXmlVersion, [:pointer], :pointer
    attach_function :xmlTextReaderReadState, [:pointer], :int
    attach_function :xmlTextReaderHasValue, [:pointer], :int
    attach_function :xmlFreeTextReader, [:pointer], :void

    # xslt
    attach_function :xsltParseStylesheetDoc, [:pointer], :pointer
    attach_function :xsltFreeStylesheet, [:pointer], :void
    attach_function :xsltApplyStylesheet, [:pointer, :pointer, :pointer], :pointer
    attach_function :xsltSaveResultToString, [:pointer, :pointer, :pointer, :pointer], :void
    attach_function :exsltRegisterAll, [], :void

    # sax
    callback :start_document_sax_func, [:pointer], :void
    callback :end_document_sax_func, [:pointer], :void
    callback :start_element_sax_func, [:pointer, :string, :pointer], :void
    callback :end_element_sax_func, [:pointer, :string], :void
    callback :characters_sax_func, [:pointer, :string, :int], :void
    callback :comment_sax_func, [:pointer, :string], :void
    callback :warning_sax_func, [:pointer, :string], :void
    callback :error_sax_func, [:pointer, :string], :void
    callback :cdata_block_sax_func, [:pointer, :string, :int], :void
    attach_function :xmlSAXUserParseMemory, [:pointer, :pointer, :pointer, :int], :int
    attach_function :xmlSAXUserParseFile, [:pointer, :pointer, :string], :int
    attach_function :xmlParseDocument, [:pointer], :int
    attach_function :xmlFreeParserCtxt, [:pointer], :void
    attach_function :htmlSAXParseFile, [:string, :pointer, :pointer, :pointer], :pointer
    attach_function :htmlSAXParseDoc, [:pointer, :pointer, :pointer, :pointer], :pointer

    # schema
    attach_function :xmlSchemaNewValidCtxt, [:pointer], :pointer
    attach_function :xmlSchemaSetValidStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void
    attach_function :xmlSchemaValidateDoc, [:pointer, :pointer], :void
    attach_function :xmlSchemaFreeValidCtxt, [:pointer], :void
    attach_function :xmlSchemaNewMemParserCtxt, [:pointer, :int], :pointer
    attach_function :xmlSchemaSetParserStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void
    attach_function :xmlSchemaParse, [:pointer], :pointer
    attach_function :xmlSchemaFreeParserCtxt, [:pointer], :void

    # relaxng
    attach_function :xmlRelaxNGNewValidCtxt, [:pointer], :pointer
    attach_function :xmlRelaxNGSetValidStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void
    attach_function :xmlRelaxNGValidateDoc, [:pointer, :pointer], :void
    attach_function :xmlRelaxNGFreeValidCtxt, [:pointer], :void
    attach_function :xmlRelaxNGNewMemParserCtxt, [:pointer, :int], :pointer
    attach_function :xmlRelaxNGSetParserStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void
    attach_function :xmlRelaxNGParse, [:pointer], :pointer
    attach_function :xmlRelaxNGFreeParserCtxt, [:pointer], :void
  end

  # initialize constants
  LIBXML_PARSER_VERSION = LibXML.__xmlParserVersion().read_pointer.read_string
  LIBXML_VERSION = lambda {
    LIBXML_PARSER_VERSION =~ /^(\d)(\d{2})(\d{2})$/
    major = $1.to_i
    minor = $2.to_i
    bug   = $3.to_i
    "#{major}.#{minor}.#{bug}"
  }.call
end

require 'nokogiri/syntax_error'
require 'nokogiri/xml/syntax_error'

[ "structs/common_node",
  "structs/xml_alloc",
  "structs/xml_document",
  "structs/xml_node",
  "structs/xml_dtd",
  "structs/xml_notation",
  "structs/xml_node_set",
  "structs/xml_xpath_context",
  "structs/xml_xpath",
  "structs/xml_xpath_object.rb",
  "structs/xml_xpath_parser_context.rb",
  "structs/xml_buffer",
  "structs/xml_syntax_error",
  "structs/xml_attr.rb",
  "structs/xml_ns.rb",
  "structs/xml_schema.rb",
  "structs/xml_relax_ng.rb",
  "structs/xml_text_reader.rb",
  "structs/xml_sax_handler.rb",
  "structs/html_elem_desc",
  "structs/html_entity_desc",
  "structs/xslt_stylesheet.rb",
  "xml/node.rb",
  "xml/dtd.rb",
  "xml/attr.rb",
  "xml/document.rb",
  "xml/document_fragment.rb",
  "xml/schema.rb",
  "xml/relax_ng.rb",
  "xml/text.rb",
  "xml/cdata.rb",
  "xml/comment.rb",
  "xml/node_set.rb",
  "xml/xpath.rb",
  "xml/xpath_context.rb",
  "xml/syntax_error.rb",
  "xml/reader.rb",
  "xml/entity_reference.rb",
  "xml/sax/parser.rb",
  "html/document.rb",
  "html/element_description.rb",
  "html/entity_lookup.rb",
  "html/sax/parser.rb",
  "xslt/stylesheet.rb",
].each do |file|
  require File.join(File.dirname(__FILE__), file)
end


require "#{File.dirname(__FILE__)}/../../../cross-ffi"

module CrossFFI
  module Primitives
    ffi_attach "#{File.dirname(__FILE__)}/../clib/libprimitives.so", :prim1_create, [:int, :float, :double, :string, :pointer], :pointer
  end
end

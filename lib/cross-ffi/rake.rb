require 'rake'

namespace :ffi do
  desc "generate platform-specific FFI struct files"
  task :generate do
    $: << "/home/mike/code/ruby-ffi~mercurial/lib"
    require 'ffi'
    require 'ffi/tools/struct_generator'
    require 'ffi/tools/generator'

    ffi_files.each do |ffi_file, ruby_file|
      unless uptodate?(ruby_file, ffi_file)
        puts "ffi: #{ffi_file} => #{ruby_file}"
        FFI::Generator.new ffi_file, ruby_file, {:cflags => '-I/usr/include/libxml2'}
      end
    end
  end

  desc "remove platform-specific FFI struct files"
  task :clean do
    ffi_files.each do |ffi_file, ruby_file|
      if File.exist? ruby_file
        puts "ffi: removing #{ruby_file}"
        FileUtils.rm ruby_file
      end
    end
  end

  desc "list FFI layout files"
  task :list do
    ffi_files.each { |ffi_file, _| puts "ffi: #{ffi_file}" }
  end

  def ffi_files
    require 'find'
    files = []
    Find.find("lib") { |f| files << f if f =~ /\.rb\.ffi$/ }
    files.collect { |ffi_file| [ffi_file, ffi_file.gsub(/\.ffi$/,'')] }
  end
end

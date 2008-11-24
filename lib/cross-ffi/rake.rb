require 'rake'

namespace :ffi do
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


  desc "test cross-ffi layer"
  task :test => ['test:build'] do
    require 'find'
    files = []
    Find.find(File.join(File.dirname(__FILE__),"test")) do |file|
      files << file if file =~ /.*_test.rb/
    end
    files.each { |file| require file }
  end

  namespace :test do
    desc "build test library"
    task :build do
      Dir.chdir(File.join(File.dirname(__FILE__),'test','clib')) { sh 'make' }
      ffi_generate(File.join(File.dirname(__FILE__),'test'), {:cflags => "-I."})
    end
  end

  def ffi_files(dir=nil)
    require 'find'
    files = []
    dir = dir || ENV['FFI_DIR'] || 'lib'
    Find.find(dir) { |f| files << f if f =~ /\.rb\.ffi$/ }
    files.collect { |ffi_file| [ffi_file, ffi_file.gsub(/\.ffi$/,'')] }
  end

  def ffi_generate(dir, options={})
    require 'ffi'
    require 'ffi/tools/generator'
    require 'ffi/tools/struct_generator'

    ffi_files(dir).each do |ffi_file, ruby_file|
      unless uptodate?(ruby_file, ffi_file)
        puts "ffi: #{ffi_file} => #{ruby_file}"
        FFI::Generator.new ffi_file, ruby_file, options
      end
    end
  end

end


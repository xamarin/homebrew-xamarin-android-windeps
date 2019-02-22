class MingwZlib < Formula
  desc "zlib build for MinGW"
  homepage "https://zlib.net/"
  url "https://zlib.net/zlib-1.2.11.tar.gz"
  version "1.2.11"
  sha256 "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"
  
  bottle :unneded
  depends_on "mingw-w64"

  def targets
    ["i686-w64-mingw32", "x86_64-w64-mingw32"].freeze
  end

  def install
    targets.each do |target|
      mkdir "build-#{target}" do
        system "ln -s ../*.[ch] ../*.pc.in ../test ../win32 ."
        system "make -f win32/Makefile.gcc PREFIX=#{target}- DESTDIR=#{prefix} BINARY_PATH=/usr/#{target}/lib INCLUDE_PATH=/usr/#{target}/include LIBRARY_PATH=/usr/#{target}/lib SHARED_MODE=1 prefix=/usr install"
      end
    end
  end

  def caveats; <<~EOS

    In order to use Win32/Win64 zlib in your program you will need to pass the following flags
    to MinGW compilers:

      * Win32
        -L#{prefix}/usr/i686-w64-mingw32/lib
        -I#{prefix}/usr/i686-w64-mingw32/include

      * Win64
        -L#{prefix}/usr/x86_64-w64-mingw32/lib
        -I#{prefix}/usr/x86_64-w64-mingw32/include

  EOS
  end
  
  def post_install
      # Code commented out for now because for some reason symlink creation fails when executed
      # from this script but it *works* when ln -sf is executed from command line on the same
      # machine with exactly the same parameters. No clue what's going on
#     mingw_root = File.realpath("#{Formula["mingw-w64"].prefix}")
#     link_to_mingw "i686-w64-mingw32", "i686", mingw_root
#     link_to_mingw "x86_64-w64-mingw32", "x86_64", mingw_root
  end

  def link_to_mingw(target, toolchain, mingw_root)

      
    Dir.glob("#{prefix}/usr/#{target}/include/*.h") do |from|
      src = Pathname.new "#{mingw_root}/toolchain-#{toolchain}/#{target}/include"
      dest = Pathname.new(from).relative_path_from(src)
      Dir.chdir(src) do
        ln_sf dest, File.basename(from)
      end
    end
    
    Dir.glob("#{prefix}/usr/#{target}/lib/*.*") do |from|
      src = Pathname.new "#{mingw_root}/toolchain-#{toolchain}/#{target}/lib"
      dest = Pathname.new(from).relative_path_from(src)
      Dir.chdir(src) do
        ln_sf dest, File.basename(from)
      end
    end
  end
end

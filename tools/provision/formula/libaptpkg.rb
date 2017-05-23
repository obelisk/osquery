require File.expand_path("../Abstract/abstract-osquery-formula", __FILE__)

class Libaptpkg < AbstractOsqueryFormula
  desc "The low-level bindings for apt-pkg"
  homepage "https://apt.alioth.debian.org/python-apt-doc/library/apt_pkg.html"
  url "https://github.com/Debian/apt/archive/1.3.1.tar.gz"
  sha256 "a91a5e96417aad33f236234730b2a0bed3a028d6fc01c57d060b7d92746bf65a"
  revision 100

  bottle do
    root_url "https://osquery-packages.s3.amazonaws.com/bottles"
    cellar :any_skip_relocation
    sha256 "cdecad1ae6bb89192a7df50c1f818f71696621239905eabc3ea2aeadddd0437e" => :x86_64_linux
  end

  depends_on "lz4"

  patch :DATA

  def install
    args = osquery_cmake_args
    args << "-DWITH_DOC=NO"
    args << "-DUSE_NLS=NO"

    system "cmake", *args
    system "make"

    mkdir_p "#{prefix}/lib"
    system "cp", "apt-pkg/libapt-pkg.a", "#{prefix}/lib/"
    mkdir_p "#{prefix}/include/apt-pkg"
    system "cp include/apt-pkg/*.h #{prefix}/include/apt-pkg/"
  end
end

__END__
diff --git a/CMake/Documentation.cmake b/CMake/Documentation.cmake
index f3bbfdc..f37b82c 100644
--- a/CMake/Documentation.cmake
+++ b/CMake/Documentation.cmake
@@ -24,6 +24,7 @@
 # SOFTWARE.
 
 
+if(WITH_DOC)
 find_path(DOCBOOK_XSL manpages/docbook.xsl
          # Debian
          /usr/share/xml/docbook/stylesheet/docbook-xsl
@@ -43,6 +44,7 @@ find_path(DOCBOOK_XSL manpages/docbook.xsl
 if(NOT DOCBOOK_XSL)
     message(FATAL_ERROR "Could not find docbook xsl")
 endif()
+endif()
 
 configure_file(${CMAKE_CURRENT_SOURCE_DIR}/docbook-text-style.xsl.cmake.in
                 ${CMAKE_CURRENT_BINARY_DIR}/docbook-text-style.xsl)
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 19d8728..47a527f 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -197,17 +197,17 @@ configure_file(CMake/config.h.in ${PROJECT_BINARY_DIR}/include/config.h)
 configure_file(CMake/apti18n.h.in ${PROJECT_BINARY_DIR}/include/apti18n.h)
 
 # Add our subdirectories
-add_subdirectory(vendor)
+#add_subdirectory(vendor)
 add_subdirectory(apt-pkg)
-add_subdirectory(apt-private)
-add_subdirectory(apt-inst)
-add_subdirectory(cmdline)
-add_subdirectory(completions)
-add_subdirectory(doc)
-add_subdirectory(dselect)
-add_subdirectory(ftparchive)
-add_subdirectory(methods)
-add_subdirectory(test)
+#add_subdirectory(apt-private)
+#add_subdirectory(apt-inst)
+#add_subdirectory(cmdline)
+#add_subdirectory(completions)
+#add_subdirectory(doc)
+#add_subdirectory(dselect)
+#add_subdirectory(ftparchive)
+#add_subdirectory(methods)
+#add_subdirectory(test)
 
 if (USE_NLS)
 add_subdirectory(po)
diff --git a/apt-pkg/CMakeLists.txt b/apt-pkg/CMakeLists.txt
index 1b493c8..dad5c8c 100644
--- a/apt-pkg/CMakeLists.txt
+++ b/apt-pkg/CMakeLists.txt
@@ -21,7 +21,7 @@ file(GLOB_RECURSE library "*.cc")
 file(GLOB_RECURSE headers "*.h")
 
 # Create a library using the C++ files
-add_library(apt-pkg SHARED ${library})
+add_library(apt-pkg STATIC ${library})
 add_dependencies(apt-pkg apt-pkg-versionscript)
 # Link the library and set the SONAME
 target_include_directories(apt-pkg
@@ -46,7 +46,7 @@ set_target_properties(apt-pkg PROPERTIES SOVERSION ${MAJOR})
 add_version_script(apt-pkg)
 
 # Install the library and the header files
-install(TARGETS apt-pkg LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
+install(TARGETS apt-pkg ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})
 install(FILES ${headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/apt-pkg)
 flatify(${PROJECT_BINARY_DIR}/include/apt-pkg/ "${headers}")

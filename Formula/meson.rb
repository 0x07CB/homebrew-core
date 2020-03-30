class Meson < Formula
  desc "Fast and user friendly build system"
  homepage "https://mesonbuild.com/"
  url "https://github.com/mesonbuild/meson/releases/download/0.54.0/meson-0.54.0.tar.gz"
  sha256 "dde5726d778112acbd4a67bb3633ab2ee75d33d1e879a6283a7b4a44c3363c27"
  head "https://github.com/mesonbuild/meson.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "674b211a427f97e52b1a517fc606de85b43fc3ebd7c7387abe9a7aafb5b5172c" => :catalina
    sha256 "674b211a427f97e52b1a517fc606de85b43fc3ebd7c7387abe9a7aafb5b5172c" => :mojave
    sha256 "674b211a427f97e52b1a517fc606de85b43fc3ebd7c7387abe9a7aafb5b5172c" => :high_sierra
    sha256 "3162da4a9e14dc23ccfa9d0679bae07d215db5e2623ddaa653ea2c3d28e7530f" => :x86_64_linux
  end

  depends_on "ninja"
  depends_on "python"

  # https://github.com/mesonbuild/meson/issues/2567#issuecomment-504581379
  patch :DATA

  def install
    version = Language::Python.major_minor_version("python3")
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"

    system "python3", *Language::Python.setup_install_args(prefix)

    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"helloworld.c").write <<~EOS
      main() {
        puts("hi");
        return 0;
      }
    EOS
    (testpath/"meson.build").write <<~EOS
      project('hello', 'c')
      executable('hello', 'helloworld.c')
    EOS

    mkdir testpath/"build" do
      system "#{bin}/meson", ".."
      assert_predicate testpath/"build/build.ninja", :exist?
    end
  end
end
__END__
--- meson-0.47.2.orig/mesonbuild/minstall.py
+++ meson-0.47.2/mesonbuild/minstall.py
@@ -486,8 +486,11 @@ class Installer:
                         printed_symlink_error = True
             if os.path.isfile(outname):
                 try:
-                    depfixer.fix_rpath(outname, install_rpath, final_path,
-                                       install_name_mappings, verbose=False)
+                    if install_rpath:
+                        depfixer.fix_rpath(outname, install_rpath, final_path,
+                                           install_name_mappings, verbose=False)
+                    else:
+                        print("RPATH changes at install time disabled")
                 except SystemExit as e:
                     if isinstance(e.code, int) and e.code == 0:
                         pass

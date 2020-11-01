class Valabind < Formula
  desc "Vala bindings for radare, reverse engineering framework"
  homepage "https://github.com/radare/valabind"
  url "https://github.com/radare/valabind/archive/1.7.2.tar.gz"
  sha256 "643c1ddc85e31de975df361a20e3f39d385f5ced0e50483c6e96b33bb3d32261"
  license "GPL-3.0-or-later"
  head "https://github.com/radare/valabind.git"

  bottle do
    cellar :any
    sha256 "e34f9429315d89d56a6fae0264a874d8502498367cc7fe0689bd2ade0ba247b2" => :catalina
    sha256 "bd3e953ae31b4a28fe43f7ec7ba12df304073796bd4384839cef7220bbcdd603" => :mojave
    sha256 "2cb71440c4d1e3716e3f669c66ec3942f80f56c08250130691daea0eab58dbb3" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "swig"
  depends_on "vala"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  def install
    unless OS.mac?
      # Valabind depends on the Vala code generator library during execution.
      # The `libvala` pkg-config file installed by brew isn't pointing to Vala's
      # opt_prefix so Valabind will break as soon as Vala releases a new
      # patchlevel. This snippet modifies the Makefile to point to Vala's
      # `opt_prefix` instead.
      vala = Formula["vala"]
      pre_ver = vala.prefix(vala.version)
      inreplace "Makefile",
                /^VALA_PKGLIBDIR=(.*$)/,
                "VALA_PKGLIBDIR_=\\1\nVALA_PKGLIBDIR=$(subst #{pre_ver},#{vala.opt_prefix},$(VALA_PKGLIBDIR_))"
    end

    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system bin/"valabind", "--help"
  end
end

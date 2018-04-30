class LcdfTypetools < Formula
  desc "Manipulate OpenType and multiple-master fonts"
  homepage "https://www.lcdf.org/type/"
  url "https://www.lcdf.org/type/lcdf-typetools-2.107.tar.gz"
  sha256 "46be885f4623e2e595f786c70e03264b680066de57789833db541f947a8edfdb"

  bottle do
    sha256 "bc3f49aef8137633d403aaa90ed1f97e9e0e07ec969b424649fd3a2d8408dd9c" => :high_sierra
    sha256 "9875de167b838b6ef49eb83400f1b9c306c0374394a33f46cec6e7cceb0ed066" => :sierra
    sha256 "761612b6522dffab0ea197e1ff27422bc8d34ffaf080518d148249bf7731e3ed" => :el_capitan
    sha256 "f7a95d76120b54ac63d07cf3c886cc0d379ebc75545e40e1e0c1de7ff87d1573" => :x86_64_linux
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-kpathsea"
    system "make", "install"
  end

  test do
    assert_match "STIXGeneral-Regular",
      shell_output("#{bin}/otfinfo -p /Library/Fonts/STIXGeneral.otf")
  end
end

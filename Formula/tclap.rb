class Tclap < Formula
  desc "Templatized C++ command-line parser library"
  homepage "https://tclap.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/tclap/tclap-1.2.2.tar.gz"
  sha256 "f5013be7fcaafc69ba0ce2d1710f693f61e9c336b6292ae4f57554f59fde5837"

  bottle do
    cellar :any_skip_relocation
    sha256 "8e85cfa71594680dc52d5ff18d93cf585fc5990c28316f0b60f42584ff3a2697" => :high_sierra
    sha256 "8e85cfa71594680dc52d5ff18d93cf585fc5990c28316f0b60f42584ff3a2697" => :sierra
    sha256 "8e85cfa71594680dc52d5ff18d93cf585fc5990c28316f0b60f42584ff3a2697" => :el_capitan
    sha256 "07dcfd5a5be305cdf6b1d773dadd6b0ba1bf59b784964518fd03989262f6eb1e" => :x86_64_linux
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    # Installer scripts have problems with parallel make
    ENV.deparallelize
    system "make", "install"
  end
end

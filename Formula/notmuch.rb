class Notmuch < Formula
  desc "Thread-based email index, search, and tagging"
  homepage "https://notmuchmail.org/"
  url "https://notmuchmail.org/releases/notmuch-0.27.tar.gz"
  sha256 "40d3192f8f130f227b511fc80be86310c7f60ccb6d043b563f201fa505de0876"
  head "https://git.notmuchmail.org/git/notmuch", :using => :git

  bottle do
    cellar :any
    rebuild 2
    sha256 "85ed63058e3f8a62375e9df08963fdcf06423cfa8e8e42b1b43952b93d5828b6" => :mojave
    sha256 "241b8649b30055854bfea7f0540099895e7915402c5b278ef5db838545f006a7" => :high_sierra
    sha256 "bc53f8af373350cb3a993ca381eaaf1245d70874e24611c9a7e95568e96f922a" => :sierra
    sha256 "94b1ecd019c98b646db669da75b624752a348b0f9ca24761a29d486f5e4819a0" => :x86_64_linux
  end

  depends_on "doxygen" => :build
  depends_on "libgpg-error" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build
  depends_on "emacs"
  depends_on "glib"
  depends_on "gmime"
  depends_on "python@2"
  depends_on "talloc"
  depends_on "xapian"
  depends_on "zlib"
  depends_on "zlib" unless OS.mac?

  def install
    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --with-emacs
      --emacslispdir=#{elisp}
      --emacsetcdir=#{elisp}
      --without-ruby
    ]

    # Emacs and parallel builds aren't friends
    ENV.deparallelize

    system "./configure", *args
    system "make", "V=1", "install"

    cd "bindings/python" do
      system "python2.7", *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    (testpath/".notmuch-config").write "[database]\npath=#{testpath}/Mail"
    (testpath/"Mail").mkpath
    assert_match "0 total", shell_output("#{bin}/notmuch new")
  end
end

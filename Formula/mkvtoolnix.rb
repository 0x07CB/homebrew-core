class Mkvtoolnix < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://www.bunkus.org/videotools/mkvtoolnix/"
  url "https://mkvtoolnix.download/sources/mkvtoolnix-26.0.0.tar.xz"
  sha256 "d51e63c356f9f0c92cc0b01ff6e78253954c74186be6ef4c40c5690d18fda7e0"

  bottle do
    sha256 "031dbd7e9a4857a879274816d285a014c7760b7b1d26b871a9af62556a4e9477" => :mojave
    sha256 "1692e116a1223e9e09c133ee3cc4e56b586c9b910fb288e295d047042109075b" => :high_sierra
    sha256 "064613975686c3506595cb04558854e66caecd59e2e67f879758d3f315d91755" => :sierra
    sha256 "95bb0752af9db6417ebc3d797557824305d71054d347909af17c0e8f4a757df2" => :el_capitan
    sha256 "439191ad587b74285b1f67289f6a6e04f1de77d3b46356b33df0588ff494e76b" => :x86_64_linux
  end

  head do
    url "https://gitlab.com/mbunkus/mkvtoolnix.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-qt", "Build with Qt GUI"

  deprecated_option "with-qt5" => "with-qt"

  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "pugixml" => :build
  depends_on "ruby" => :build if MacOS.version <= :mountain_lion || !OS.mac?
  depends_on "boost"
  depends_on "libebml"
  depends_on "libmatroska"
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "flac" => :recommended
  depends_on "libmagic" => :recommended
  depends_on "gettext" => OS.mac? ? :optional : :recommended
  depends_on "qt" => :optional
  depends_on "cmark" if build.with? "qt"
  depends_on "libxslt" => :build unless OS.mac? # for xsltproc

  needs :cxx11

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j4" if ENV["CIRCLECI"]

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog" unless OS.mac?

    ENV.cxx11

    features = %w[libogg libvorbis libebml libmatroska]
    features << "flac" if build.with? "flac"
    features << "libmagic" if build.with? "libmagic"

    extra_includes = ""
    extra_libs = ""
    features.each do |feature|
      extra_includes << "#{Formula[feature].opt_include};"
      extra_libs << "#{Formula[feature].opt_lib};"
    end
    extra_includes.chop!
    extra_libs.chop!

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-docbook-xsl-root=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl
      --with-extra-includes=#{extra_includes}
      --with-extra-libs=#{extra_libs}
    ]

    if build.with?("qt")
      qt = Formula["qt"]

      args << "--with-moc=#{qt.opt_bin}/moc"
      args << "--with-uic=#{qt.opt_bin}/uic"
      args << "--with-rcc=#{qt.opt_bin}/rcc"
      args << "--enable-qt"
    else
      args << "--disable-qt"
    end

    system "./autogen.sh" if build.head?

    system "./configure", *args

    system "rake", *("--trace" if ENV["CIRCLECI"]), "-j#{ENV.make_jobs}"
    system "rake", "install"
  end

  test do
    mkv_path = testpath/"Great.Movie.mkv"
    sub_path = testpath/"subtitles.srt"
    sub_path.write <<~EOS
      1
      00:00:10,500 --> 00:00:13,000
      Homebrew
    EOS

    system "#{bin}/mkvmerge", "-o", mkv_path, sub_path
    system "#{bin}/mkvinfo", mkv_path
    system "#{bin}/mkvextract", "tracks", mkv_path, "0:#{sub_path}"
  end
end

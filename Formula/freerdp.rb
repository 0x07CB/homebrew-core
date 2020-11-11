class Freerdp < Formula
  desc "X11 implementation of the Remote Desktop Protocol (RDP)"
  homepage "https://www.freerdp.com/"
  url "https://github.com/FreeRDP/FreeRDP/archive/2.2.0.tar.gz"
  sha256 "883bc0396c6be9aba6bc07ebc8ff08457125868ada0f06554e62ef072f90cf59"
  license "Apache-2.0"
  revision OS.mac? ? 1 : 3

  bottle do
    sha256 "500faf5c949356095126fc08fd1f5bd71ee2254cdb7f65e7ac38cbfde151911d" => :catalina
    sha256 "a97258802689aebfb320f3649a9fa36389c885953afb211f9b54962eec8a87f7" => :mojave
    sha256 "8c95c86605b16b6a524b720f70c783c9a77e50719d49cd02a0624da03e4cf92d" => :high_sierra
    sha256 "a5ef20fd7dc9ba453af09c2e5d673da54a9268e89dbcf497a5dead024e9e83ef" => :x86_64_linux
  end

  head do
    url "https://github.com/FreeRDP/FreeRDP.git"
    depends_on xcode: :build
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libusb"
  depends_on "libx11"
  depends_on "libxcursor"
  depends_on "libxext"
  depends_on "libxfixes"
  depends_on "libxi"
  depends_on "libxinerama"
  depends_on "libxrandr"
  depends_on "libxrender"
  depends_on "libxv"
  depends_on "openssl@1.1"

  on_linux do
    depends_on "alsa-lib"
    depends_on "ffmpeg"
    depends_on "glib"
  end

  unless OS.mac?
    depends_on "systemd"
    depends_on "linuxbrew/xorg/wayland"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DWITH_X11=ON" << "-DBUILD_SHARED_LIBS=ON"
    unless OS.mac?
      cmake_args << "-DWITH_CUPS=OFF"
      # cmake_args << "-DWITH_FFMPEG=OFF"
      # cmake_args << "-DWITH_ALSA=OFF"
      # cmake_args << "-DWITH_LIBSYSTEMD=OFF"
    end
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    # failed to open display
    return if ENV["CI"]

    success = `#{bin}/xfreerdp --version` # not using system as expected non-zero exit code
    details = $CHILD_STATUS
    raise "Unexpected exit code #{$CHILD_STATUS} while running xfreerdp" if !success && details.exitstatus != 128
  end
end

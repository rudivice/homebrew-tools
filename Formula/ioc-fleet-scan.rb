# typed: false
# frozen_string_literal: true

# ioc-fleet-scan — npm Supply-Chain IoC scanner for macOS fleets.
#
# Private repo — uses git+SSH so Homebrew clones via the user's GitHub SSH key.
# The Swift CLI lives in the `swift/` subdirectory of the source repo.
class IocFleetScan < Formula
  desc "npm Supply-Chain IoC scanner for macOS fleets"
  homepage "https://github.com/rudivice/ioc-fleet-scan"
  url "git@github.com:rudivice/ioc-fleet-scan.git",
      using:    :git,
      tag:      "v1.0.1",
      revision: "31be037bde85d5592f9ddd98d85d4ca55792bd64"
  license "MIT"
  version "1.0.1"
  head "git@github.com:rudivice/ioc-fleet-scan.git", using: :git, branch: "main"

  depends_on xcode: ["13.0", :build]

  def install
    cd "swift" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/ioc-scan"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ioc-scan --version")
    assert_match "Usage:", shell_output("#{bin}/ioc-scan --help")
  end
end

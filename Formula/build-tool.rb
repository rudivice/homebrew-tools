# typed: false
# frozen_string_literal: true

# build-tool — Universal build/sign/notarize/release tool for Swift CLI projects.
#
# Source: https://github.com/rudivice/swift-build-tool
# Tap:    rudivice/tools (private)
#
# Maintained by the `brew-tap-add` agent skill. To bump:
#   In the source repo: git tag v1.x.y && git push --tags
#   Then: invoke `brew-tap-add build-tool v1.x.y` and confirm the diff.
class BuildTool < Formula
  desc "Universal build/sign/notarize/release tool for Swift CLI projects"
  homepage "https://github.com/rudivice/swift-build-tool"
  url "git@github.com:rudivice/swift-build-tool.git",
      using:    :git,
      tag:      "v1.0.0",
      revision: "d0a08c9e0bb9cd020244836f6cdf03a76d5c89ce"
  license "MIT"
  version "1.0.0"
  head "git@github.com:rudivice/swift-build-tool.git", using: :git, branch: "main"

  depends_on xcode: ["15.0", :build]
  # macOS minimum is enforced by Package.swift's `platforms:` declaration.

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/build-tool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/build-tool --version")
  end
end

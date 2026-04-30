# typed: false
# frozen_string_literal: true

# immotest — Remote data checker for Immotool PHP files converted to JSON.
#
# Source: https://github.com/rudivice/immotest
# Tap:    rudivice/tools (private)
#
# Maintained by the `brew-tap-add` agent skill. To bump:
#   In the source repo: git tag v1.x.y && git push --tags
#   Then: invoke `brew-tap-add immotest v1.x.y` and confirm the diff.
class Immotest < Formula
  desc "Remote data checker for Immotool PHP files converted to JSON"
  homepage "https://github.com/rudivice/immotest"
  url "git@github.com:rudivice/immotest.git",
      using:    :git,
      tag:      "v1.5.10",
      revision: "a6434323fe3f3ff6db07e18f2a5b18c509fab882"
  license "MIT"
  version "1.5.10"
  head "git@github.com:rudivice/immotest.git", using: :git, branch: "main"

  depends_on xcode: ["15.0", :build]
  # macOS minimum is enforced by Package.swift's `platforms:` declaration.

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/immotest"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/immotest --version")
  end
end

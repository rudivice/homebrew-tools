# typed: false
# frozen_string_literal: true

# cb-emailcheck — Verify CB support email messages by recomputing the MD5 hash.
#
# Source: https://github.com/rudivice/cb-emailcheck
# Tap:    rudivice/tools (private)
#
# Maintained by the `brew-tap-add` agent skill. To bump:
#   In the source repo: git tag v1.x.y && git push --tags
#   Then: invoke `brew-tap-add cb-emailcheck v1.x.y` and confirm the diff.
class CbEmailcheck < Formula
  desc "Verify CB support email messages based on app variants and MD5 hashes"
  homepage "https://github.com/rudivice/cb-emailcheck"
  url "git@github.com:rudivice/cb-emailcheck.git",
      using:    :git,
      tag:      "v1.5.8",
      revision: "0cf5034bf6ad89c8558381f86b8d86c010cf7ef9"
  version "1.5.8"
  head "git@github.com:rudivice/cb-emailcheck.git", using: :git, branch: "master"

  depends_on xcode: ["15.0", :build]
  # macOS minimum is enforced by Package.swift's `platforms:` declaration.

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/cb-emailcheck"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cb-emailcheck --version")
  end
end

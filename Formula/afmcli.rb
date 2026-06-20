# typed: false
# frozen_string_literal: true

# afmcli — Apple Foundation Models CLI for Jenkins/CI workflows.
#
# Private repo — uses git+SSH so Homebrew clones via the user's GitHub SSH key.
# Requires macOS 26 (Tahoe), Apple Silicon, and Apple Intelligence enabled
# in System Settings for the on-device LLM path; otherwise the tool falls
# back to deterministic no-LLM output (still exits 0, ok: false).
class Afmcli < Formula
  desc "Apple Foundation Models CLI for Jenkins/CI workflows on macOS 26 Mac agents"
  homepage "https://github.com/rudivice/afmcli"
  url "git@github.com:rudivice/afmcli.git",
      using:    :git,
      tag:      "v0.1.0",
      revision: "e430142d84e1502bc92da5c188a47c5972722407"
  version "0.1.0"
  head "git@github.com:rudivice/afmcli.git", using: :git, branch: "master"

  depends_on xcode: ["16.0", :build]

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--arch", "arm64"
    bin.install ".build/release/afmcli"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/afmcli --version")
    # afmcli doctor exits 2 unless Apple Intelligence is enabled — not asserted in the brew test box.
  end
end

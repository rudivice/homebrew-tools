# typed: false
# frozen_string_literal: true

# enerkita — CLI for the ener:kita energy monitoring platform.
#
# Private repo — uses git+SSH so Homebrew clones via the user's GitHub SSH key.
class Enerkita < Formula
  desc "CLI for ener:kita energy monitoring (import, reports, anomalies, MCP server)"
  homepage "https://github.com/rudivice/enerkita-cli"
  url "git@github.com:rudivice/enerkita-cli.git",
      using:    :git,
      tag:      "v1.0.0",
      revision: "4bcc52b5579fcf143eeb0547d09a43ead5b34a29"
  license "Apache-2.0"
  version "1.0.0"
  head "git@github.com:rudivice/enerkita-cli.git", using: :git, branch: "master"

  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/enerkita"
  end

  test do
    assert_match "USAGE: enerkita", shell_output("#{bin}/enerkita --help")
  end
end

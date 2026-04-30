# typed: false
# frozen_string_literal: true

# bookmarker — audit and clean Safari bookmarks; feeds a personal knowledge graph.
#
# This formula uses the git+SSH URL because rudivice/bookmarker is currently a
# private repository. SSH-based git URLs let Homebrew clone via the user's
# existing GitHub SSH key without needing a Personal Access Token.
#
# When the repo flips public, switching to the standard tarball form is a
# small change:
#
#     url      "https://github.com/rudivice/bookmarker/archive/refs/tags/v1.x.y.tar.gz"
#     sha256   "<sha256 of that tarball>"
#
# `dist/homebrew/release.sh` in the bookmarker repo bumps `tag` + `revision`
# (and prints the next-step commands) for new releases.
class Bookmarker < Formula
  desc "Audit and clean Safari bookmarks; feeds a personal knowledge graph"
  homepage "https://github.com/rudivice/bookmarker"
  url "git@github.com:rudivice/bookmarker.git",
      tag:      "v1.1.0",
      revision: "061fd174ec322522e4eb9a942862787b462a97f2"
  license "Apache-2.0"
  version "1.1.0"
  head "git@github.com:rudivice/bookmarker.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on macos: ">= :ventura"

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/bookmarker"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bookmarker --version")
  end
end

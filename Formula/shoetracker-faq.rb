# typed: false
# frozen_string_literal: true

# shoetracker-faq — manage ShoeTracker FAQ entries (local seed ↔ CloudKit).
#
# Must be run from the ShoeTracker project root so it can find
# `Shoe Tracker/Resources/faq-seed.json`.
#
# The source lives inside the ShoeTracker repo at tools/shoetracker-faq/.
# This formula builds from that subdirectory via git+SSH.
class ShoetrackerFaq < Formula
  desc "Manage ShoeTracker FAQ entries (local seed ↔ CloudKit)"
  homepage "https://github.com/rudivice/ShoeTracker"
  url "git@github.com:rudivice/ShoeTracker.git",
      using:    :git,
      tag:      "shoetracker-faq-v1.0.0",
      revision: "408a71b086fc385617f13658b835e67914a676d7"
  license "MIT"
  version "1.0.0"
  head "git@github.com:rudivice/ShoeTracker.git", using: :git, branch: "main"

  deprecate! date: "2026-05-18",
             because: "superseded by the unified `shoetracker` CLI (1.3.0+) " \
                      "which handles FAQ, AppConfig, catalog, schema, and doctor. " \
                      "Migrate via `brew uninstall shoetracker-faq && brew install rudivice/tools/shoetracker`."

  depends_on xcode: ["16.0", :build]

  def install
    cd "tools/shoetracker-faq" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/shoetracker-faq"
    end
  end

  def caveats
    <<~EOS
      ⚠️  DEPRECATED — replaced by the unified `shoetracker` CLI.

      Migrate now:
        brew uninstall shoetracker-faq
        brew install rudivice/tools/shoetracker

      Command mapping:
        shoetracker-faq <cmd>   →  shoetracker faq <cmd>
        e.g.
        shoetracker-faq push    →  shoetracker faq push
        shoetracker-faq deploy  →  shoetracker faq deploy --env production
        shoetracker-faq diff    →  shoetracker faq diff

      Plus everything else the new CLI adds:
        shoetracker config <…>   # AppConfig values
        shoetracker catalog <…>  # Shoe catalog (search, add wizard, …)
        shoetracker schema <…>   # CloudKit schema plan/verify
        shoetracker doctor       # Environment diagnostics

      Requires:
        - Server-to-server key: ~/.config/shoetracker/cloudkit-key.pem
        - SSH deploy key: ~/.ssh/so-simple-deploy (for deploy/hugo --deploy)
    EOS
  end

  test do
    assert_match "USAGE: shoetracker-faq", shell_output("#{bin}/shoetracker-faq --help")
  end
end

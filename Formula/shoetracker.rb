# typed: false
# frozen_string_literal: true

# shoetracker — universal CLI for ShoeTracker CloudKit Public-DB
# management. Handles FAQ entries, AppConfig values, and ships with a
# Safety pipeline (backup → diff → confirm → audit) plus a Doctor
# subcommand for environment checks.
#
# Replaces the older `shoetracker-faq` formula. Must be run from the
# ShoeTracker project root so it can find the JSON seed files at
# `Shoe Tracker/Resources/`.
class Shoetracker < Formula
  desc "Universal CLI for ShoeTracker CloudKit Public-DB management"
  homepage "https://github.com/rudivice/ShoeTracker"
  url "git@github.com:rudivice/ShoeTracker.git",
      using:    :git,
      tag:      "shoetracker-v1.2.0",
      revision: "b4a7d2adfc718b1edeaa5ae25b5511d86fb01902"
  license "MIT"
  version "1.2.0"
  head "git@github.com:rudivice/ShoeTracker.git", using: :git, branch: "main"

  depends_on xcode: ["26.0", :build]

  def install
    cd "tools/shoetracker" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/shoetracker"
    end
    # Daily-driver alias: `st <subcommand>`
    bin.install_symlink bin/"shoetracker" => "st"
  end

  def caveats
    <<~EOS
      Run from the ShoeTracker project root:
        cd ~/Development/ShoeTracker

      Subcommand groups:
        shoetracker faq <push|pull|show|diff|stats|deploy|hugo>
        shoetracker config <keys|get|set|pull|push>
        shoetracker catalog <list|show|add|import|pull|push|remove>
        shoetracker schema <plan|verify>
        shoetracker doctor

      A `st` symlink is installed as a 2-letter alias:
        st config keys
        st faq diff
        st doctor

      Migration from shoetracker-faq:
        brew uninstall shoetracker-faq

      Requires:
        - Server-to-server key: ~/.config/shoetracker/cloudkit-key.pem (mode 600)
        - SSH deploy key: ~/.ssh/so-simple-deploy (for faq deploy/hugo --deploy)
    EOS
  end

  test do
    assert_match "USAGE: shoetracker", shell_output("#{bin}/shoetracker --help")
    assert_match "USAGE: shoetracker", shell_output("#{bin}/st --help")
  end
end

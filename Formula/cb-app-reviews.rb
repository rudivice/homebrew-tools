# typed: false
# frozen_string_literal: true

# cb-app-reviews — pull App Store & Google Play reviews for the 9 CB apps, translate to
# German (DeepL), store in SQLite, and post new ones to Slack. Also queries the DB.
#
# Source: https://github.com/rudivice/cb-app-reviews (private)
# Tap:    rudivice/tools (private)
#
# The Swift package lives in `swift/`; the shared `contract/` (config.json, schema.sql)
# is installed to share/ and found executable-relative at runtime.
#
# Maintained by the `brew-tap-add` agent skill. To bump:
#   In the source repo: git tag v0.x.y && git push --tags
#   Then: invoke `brew-tap-add cb-app-reviews v0.x.y` and confirm the diff.
class CbAppReviews < Formula
  desc "Fetch, translate, store and Slack-post reviews for the CB apps"
  homepage "https://github.com/rudivice/cb-app-reviews"
  url "git@github.com:rudivice/cb-app-reviews.git",
      using:    :git,
      tag:      "v0.1.0",
      revision: "50f44f5df70d3dfed18554d49d41c81dde12c991"
  version "0.1.0"
  head "git@github.com:rudivice/cb-app-reviews.git", using: :git, branch: "master"

  depends_on xcode: ["16.0", :build]

  def install
    cd "swift" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/cb-app-reviews"
    end
    # Shared contract — found at runtime via <bin>/../share/cb-app-reviews/.
    pkgshare.install Dir["contract/*"]
  end

  def caveats
    <<~EOS
      Credentials are read from the environment first, then 1Password (`op`). For a
      headless run export the service-account token so op needs no Touch ID:
        export OP_SERVICE_ACCOUNT_TOKEN=...

      Usage:
        cb-app-reviews --seed --db ~/cb-reviews.db       # seed baseline (no posting)
        cb-app-reviews --db ~/cb-reviews.db --limit 50   # poll: fetch -> translate -> post
        cb-app-reviews --db ~/cb-reviews.db --query "rating=5 month=2026-06 group=store"
        cb-app-reviews --query help
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cb-app-reviews --version")
  end
end

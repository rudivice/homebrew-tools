# typed: false
# frozen_string_literal: true

require "download_strategy"

# Download a release asset from a PRIVATE GitHub repo using HOMEBREW_GITHUB_API_TOKEN.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    pattern = %r{https://github.com/(?<owner>[^/]+)/(?<repo>[^/]+)/releases/download/(?<tag>[^/]+)/(?<filename>.+)}
    raise CurlDownloadStrategyError, "Invalid GitHub release URL." unless @url =~ pattern

    @owner = Regexp.last_match(:owner)
    @repo = Regexp.last_match(:repo)
    @tag = Regexp.last_match(:tag)
    @filename = Regexp.last_match(:filename)
  end

  def download_url
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url,
                  "--header", "Accept: application/octet-stream",
                  "--header", "Authorization: token #{@github_token}",
                  to: temporary_path
  end

  def set_github_token
    @github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
    return if @github_token

    raise CurlDownloadStrategyError,
          "Set HOMEBREW_GITHUB_API_TOKEN (a token with repo access) to download this private release asset."
  end

  def asset_id
    @asset_id ||= begin
      release = GitHub::API.open_rest("#{GitHub::API_URL}/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}")
      asset = release["assets"].find { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Release asset #{@filename} not found." unless asset

      asset["id"]
    end
  end
end

# cb-app-reviews — pull App Store & Google Play reviews for the CB apps, translate to
# German (DeepL), store in SQLite, and post new ones to Slack. Also queries the DB.
#
# Distributed as a prebuilt, Developer-ID-signed + notarized arm64 binary (no build, no
# Xcode). Source (private): https://github.com/rudivice/cb-app-reviews
#
# Requires HOMEBREW_GITHUB_API_TOKEN (a token with read access to the private repo).
# Bump: run scripts/release-binary.sh in the source repo, upload the tarball to the
# release, then update url + sha256 here (via `brew-tap-add cb-app-reviews vX.Y.Z`).
class CbAppReviews < Formula
  desc "Fetch, translate, store and Slack-post reviews for the CB apps"
  homepage "https://github.com/rudivice/cb-app-reviews"
  url "https://github.com/rudivice/cb-app-reviews/releases/download/v0.8.0/cb-app-reviews-0.8.0-arm64.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  version "0.8.0"
  sha256 "bcdae7bf19dd7defd917d5c5b673bda30b9c3d009a14be709c27ce9f279c6d02"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    bin.install "cb-app-reviews"
    # Shared contract (config.json, schema.sql) — found at runtime via <bin>/../share/cb-app-reviews/.
    pkgshare.install Dir["contract/*"]
  end

  def caveats
    <<~EOS
      Signed (Developer ID) + notarized arm64 binary — no build needed.
      Install requires HOMEBREW_GITHUB_API_TOKEN with access to the private repo.

      Credentials at runtime come from the environment first, then 1Password (`op`).
      Headless: export OP_SERVICE_ACCOUNT_TOKEN so op needs no Touch ID.

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

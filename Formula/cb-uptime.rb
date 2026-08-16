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

# cb-uptime — pull App Store & Google Play reviews for the CB apps, translate to
# German (DeepL), store in SQLite, and post new ones to Slack. Also queries the DB.
#
# Distributed as a prebuilt, Developer-ID-signed + notarized arm64 binary (no build, no
# Xcode). Source (private): https://github.com/rudivice/cb-uptime
#
# Requires HOMEBREW_GITHUB_API_TOKEN (a token with read access to the private repo).
# Bump: run scripts/release-binary.sh in the source repo, upload the tarball to the
# release, then update url + sha256 here (via `brew-tap-add cb-uptime vX.Y.Z`).
class CbUptime < Formula
  desc "Synthetic availability monitoring for the Corporate Benefits platforms"
  homepage "https://github.com/rudivice/cb-uptime"
  url "https://github.com/rudivice/cb-uptime/releases/download/v0.1.2/cb-uptime-0.1.2-arm64.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  version "0.1.2"
  sha256 "73684a6cf04889c7f5a9e7ee154d3cb0f31e4d2c7b1b6c695943cbc5d2b0515a"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  def install
    # Binary only — unlike cb-app-reviews there is no contract/ to ship. The platform inventory is
    # data, not part of the distribution, and lives in the user's Application Support directory.
    bin.install "cb-uptime"
  end

  def caveats
    <<~EOS
      Signed (Developer ID) + notarized arm64 binary — no build needed.
      Install requires HOMEBREW_GITHUB_API_TOKEN with access to the private repo.

      The store lives at ~/Library/Application Support/cb-uptime/cb-uptime.sqlite and is
      created on first use. Seed the inventory from a platform export before the first run.

      Credentials for the authenticated chain come from the environment first, then 1Password.
      Headless: export OP_SERVICE_ACCOUNT_TOKEN so op needs no Touch ID.

      Usage:
        cb-uptime import <export.csv>              # seed the platform inventory
        cb-uptime check                            # one run: fixed targets + rotating sample
        cb-uptime probe https://example.com        # one URL, full timing waterfall
        cb-uptime status                           # inventory, rotation, expiring certificates
        cb-uptime backup                           # consistent snapshot + retention
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cb-uptime --version")
  end
end

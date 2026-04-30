# homebrew-tools

Private Homebrew tap for [@rudivice](https://github.com/rudivice)'s personal CLI tools.

## Add the tap

The tap is private — install via SSH so your GitHub key handles auth:

```bash
brew tap rudivice/tools git@github.com:rudivice/homebrew-tools.git
```

(Once the tap goes public, the SSH override becomes optional. Existing installs keep working unchanged.)

## Available formulae

| Formula | Status | Description |
|---|---|---|
| `bookmarker` | pending v1.1.0 tag | Audit and clean Safari bookmarks; feeds a personal knowledge graph. |
| `enerkita` | planned | _(per-tool change in [enerkita](https://github.com/rudivice/enerkita))_ |
| `cb-emailcheck` | planned | _(per-tool change in its repo)_ |
| `cb-mapp-parser` | planned | _(per-tool change in its repo)_ |
| `immotest` | planned | _(per-tool change in its repo)_ |

A formula lands here once the upstream repo cuts its first tagged release.

## Install / upgrade / uninstall

```bash
brew install bookmarker
brew upgrade bookmarker
brew uninstall bookmarker
```

`brew uninstall` removes the binary; user data under `~/Library/Application Support/<tool>/` is left intact.

## Maintainer notes

The release flow per tool lives in **its own repo**, not here. For `bookmarker` for example:

```bash
# In ~/Development/bookmarker:
git tag v1.x.y && git push --tags
dist/homebrew/release.sh v1.x.y       # patches Formula/bookmarker.rb in this clone
```

The helper script downloads the GitHub-generated tarball, computes the SHA-256, and updates the `url` / `sha256` / `version` fields. Commit + push happens manually.

## CI

`.github/workflows/audit.yml` runs `brew audit --strict ./Formula/*.rb` on every push. Catches malformed `url`, missing `sha256`, license mismatches, and a few other common formula mistakes.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

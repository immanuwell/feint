# The Homebrew tap

Live at [`immanuwell/homebrew-tap`](https://github.com/immanuwell/homebrew-tap)
since the `0.2.0` release. `feint.rb` in this directory is the source of
truth; the copy in the tap repo's `Formula/` directory is what Homebrew
actually reads.

```
brew install immanuwell/tap/feint
```

There is no `x86_64-apple-darwin` (Intel Mac) release asset yet — the
formula's `on_intel` block calls `odie` with a clear message rather than
pointing at a URL that would 404. Add that block back once that binary
exists again.

## After every release

1. Cut a release (push a `[0-9]+.[0-9]+.[0-9]+` tag; see the root README's Install
   section). Wait for the `Release` GitHub Actions workflow to finish
   building and uploading the platform archives.
2. Compute the sha256 of each archive that actually exists for this release, e.g.:

   ```
   curl -sL https://github.com/immanuwell/feint/releases/download/X.Y.Z/feint-X.Y.Z-aarch64-apple-darwin.tar.gz | sha256sum
   curl -sL https://github.com/immanuwell/feint/releases/download/X.Y.Z/feint-X.Y.Z-x86_64-unknown-linux-gnu.tar.gz | sha256sum
   ```

3. Update `version` and the `url`/`sha256` pairs in `feint.rb` to match.
4. Copy the updated file into `homebrew-tap/Formula/feint.rb`, commit, and
   push the tap repo. Takes effect immediately, no review process, since
   it's your own tap.

## Later, if it gains traction

Once feint has enough users/stars, it becomes eligible for
`homebrew-core` (Homebrew's own repo, so users get `brew install feint`
without adding a tap first). That's a separate submission process with
its own requirements (stable release history, no fast-moving deps,
etc.) — worth revisiting once the tap has been live and stable for a
while.

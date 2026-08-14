# Setting up the Homebrew tap

`feint.rb` in this directory is a template, not a live formula. Homebrew
formulas need real checksums of real release assets, so this can only go
live after a real GitHub release exists.

## One-time setup

1. Create a new GitHub repo named `homebrew-tap` under the same account
   (`immanuwell/homebrew-tap`). Homebrew requires this exact naming
   pattern for a custom tap.
2. Copy `feint.rb` into that repo's `Formula/` directory.

## After every release

1. Cut a release (push a `[0-9]+.[0-9]+.[0-9]+` tag; see the root README's Install
   section). Wait for the `Release` GitHub Actions workflow to finish
   building and uploading the platform archives.
2. Compute the sha256 of each archive:

   ```
   curl -sL https://github.com/immanuwell/feint/releases/download/X.Y.Z/feint-X.Y.Z-aarch64-apple-darwin.tar.gz | sha256sum
   curl -sL https://github.com/immanuwell/feint/releases/download/X.Y.Z/feint-X.Y.Z-x86_64-apple-darwin.tar.gz | sha256sum
   curl -sL https://github.com/immanuwell/feint/releases/download/X.Y.Z/feint-X.Y.Z-x86_64-unknown-linux-gnu.tar.gz | sha256sum
   ```

3. Update `version` and the three `url`/`sha256` pairs in `feint.rb` to
   match, and copy the updated file into `homebrew-tap/Formula/feint.rb`.
4. Commit and push the tap repo. `brew install immanuwell/tap/feint`
   works immediately, no review process, since it's your own tap.

## Later, if it gains traction

Once feint has enough users/stars, it becomes eligible for
`homebrew-core` (Homebrew's own repo, so users get `brew install feint`
without adding a tap first). That's a separate submission process with
its own requirements (stable release history, no fast-moving deps,
etc.) — worth revisiting once the tap has been live and stable for a
while.

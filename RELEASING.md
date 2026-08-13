# Releasing Terrazzo

Terrazzo publishes the Ruby gem, npm package, and GitHub Release from
`.github/workflows/release.yml`. The workflow runs when a `v*` tag is pushed and
can also be retried manually with an existing tag.

## One-time setup

Create a GitHub environment named `release`. Add approval rules there if you
want a maintainer to approve each publish.

Configure an OIDC trusted publisher for the `terrazzo` gem on RubyGems.org:

- Repository owner: `gohypelab`
- Repository name: `terrazzo`
- Workflow filename: `release.yml`
- Environment: `release`

Configure an OIDC trusted publisher for the `terrazzo` package on npmjs.com:

- Organization or user: `gohypelab`
- Repository: `terrazzo`
- Workflow filename: `release.yml`
- Environment: `release`
- Allowed action: `npm publish`

The workflow does not use long-lived RubyGems or npm publishing tokens.

## Publish a version

Update `lib/terrazzo/version.rb` and `npm/package.json` to the same version,
run the release checks, and commit the version bump. Then push the commit and an
annotated tag:

```bash
bundle exec rspec

cd npm
npm run check
cd ..

git push origin main
git tag -a v0.7.3 -m "Version 0.7.3"
git push origin v0.7.3
```

Replace `0.7.3` with the version being released. The tag, Ruby gem version, and
npm package version must match.

The workflow verifies the release, publishes any missing package versions, and
creates a GitHub Release with generated notes. If a job fails after one package
has published, rerun the workflow with the same tag; versions already present in
a registry are skipped.

## Retry an existing tag

Open **Actions → Release → Run workflow**, enter the existing tag (for example,
`v0.7.2`), and run it. This is also how to finish a release whose packages were
published manually but whose GitHub Release is missing.

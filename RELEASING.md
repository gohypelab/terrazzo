# Releasing Terrazzo

Terrazzo publishes the Ruby gem, npm package, and GitHub Release from
`.github/workflows/release.yml`. The workflow runs when a `v*` tag is pushed and
can also be retried manually with an existing tag.

The release workflow resolves the tag to a commit SHA and calls the same CI
workflow used by pull requests and `main`. Ruby checks, npm checks, the docs
audit and build, and browser system specs must all pass. Both publishing jobs
check out that verified SHA. A failed, cancelled, or skipped verification blocks
publication.

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
install dependencies, and run the release checks:

```bash
bundle install
cd spec/example_app
bundle install
cd ../..

npm --prefix npm ci
npm --prefix npm run check
npm --prefix docs ci
npm --prefix docs run check

cd spec/example_app
npm install
npm run audit
script/build_example_admin
bin/rails db:test:prepare
cd ../..

bundle exec rake check
cd spec/example_app
bundle exec rspec
cd ../..
```

Commit the version bump and push it to `main`. Wait for CI to pass for that
commit, then create and push the annotated version tag:

```bash
git tag -a v0.7.3 -m "Version 0.7.3"
git push origin v0.7.3
```

Replace `0.7.3` with the version being released. The tag, Ruby gem version, and
npm package version must match. The release workflow runs the complete
verification again because audit results can change when new vulnerabilities
are reported.

The workflow verifies the release, publishes any missing package versions, and
creates a GitHub Release with generated notes. If a job fails after one package
has published, rerun the workflow with the same tag; versions already present in
a registry are skipped.

## Retry an existing tag

Open **Actions → Release → Run workflow**, select `main`, enter the existing tag (for example,
`v0.7.2`), and run it. This is also how to finish a release whose packages were
published manually but whose GitHub Release is missing.

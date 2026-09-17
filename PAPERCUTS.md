# Papercuts

- [ ] 2026-09-17 | Release workflow | While preparing a release, the release skill required cleanup in an example app inner Git repository that no longer exists. Git resolves that directory to the parent repository. Possible improvement: use the current generated-file layout and verify the Git root before cleanup.

- [ ] 2026-09-14 | RSpec selection | While running two search spec files, the `--pattern spec/lib/**/*_spec.rb` option in `.rspec` also selected the full unit suite. Possible improvement: set the default spec directory without adding all unit files when explicit paths are supplied.

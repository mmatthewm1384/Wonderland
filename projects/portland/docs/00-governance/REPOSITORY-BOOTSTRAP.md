# Repository bootstrap

## Intended location

`/Users/wonderland/Wonderland/projects/portland/`

The scaffold archive is intended to be extracted into the `projects/` directory.
If the destination already exists, inspect and merge deliberately; do not
overwrite existing project work.

## Initial setup

```zsh
cd /Users/wonderland/Wonderland/projects/portland
git status --short
find . -maxdepth 3 -type f | sort
```

Initialize Git only after confirming this directory is not already inside an
existing repository and after reviewing the parent repository's policy.

## Bootstrap acceptance

- [ ] Root README and project configuration present.
- [ ] Governance and architecture documentation present.
- [ ] Workstream directories present.
- [ ] Data lifecycle boundaries and ignore rules present.
- [ ] No real source datasets, credentials, or personal data included.
- [ ] No global IDs falsely represented as registered.
- [ ] Existing user files preserved.

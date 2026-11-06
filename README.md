# NKP Field Docs

Practical architecture and installation guidance for Nutanix Kubernetes Platform
engineers. The site explains NKP in plain language and captures field experience;
it does not replace Nutanix support, release notes, or compatibility information.

## Documentation

The documentation is built with [MkDocs](https://www.mkdocs.org/) +
[Material](https://squidfunk.github.io/mkdocs-material/).

- Architecture pages live in `docs/architecture/`.
- Installation guides and the OpenTofu bootstrap module live in `docs/install/`.
- Node image guides live in `docs/node-images/`.
- Upgrade guides live directly in `docs/upgrades/`.

```bash
pip install -r requirements.txt
mkdocs serve   # http://127.0.0.1:8000
```

## Versions

The site has one version per NKP release, selected with the version dropdown in
the header. Versions are published with [mike](https://github.com/jimporter/mike)
to the `gh-pages` branch.

- `main` documents the current NKP version and is published as `latest`.
- Older versions live on branches named `docs/<version>`, for example
  `docs/2.18`. Each branch is published as that version.
- Guides are not separated by version folders. Each version has a single
  `install/` and `upgrades/` set that covers only that version.

To update the current version, edit `main`. To fix an older version, edit its
`docs/<version>` branch. A push to either one redeploys that version.

To move `main` to a new NKP version, for example 2.20:

1. Create `docs/2.19` from `main` and push it.
2. Update `MAIN_VERSION` in `.github/workflows/docs.yml` on `main`.
3. Update `main` for the new version.

To preview all published versions locally, run `mike serve`.

## GitHub Pages

The MkDocs site is published to
[GitHub Pages](https://jlnhnng.github.io/nkp-field-docs/) by
`.github/workflows/docs.yml`.

Every push to `main` or a `docs/*` branch runs a strict MkDocs build and then
publishes that version with mike. In the repository settings, GitHub Pages must
use **Deploy from a branch** with the `gh-pages` branch.

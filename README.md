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

## Releases

Each release marks the state of the documentation for one NKP version. Releases
are Git tags on `main`:

| Tag | Meaning |
| --- | --- |
| `v2.19.0` | Documentation for NKP 2.19.0. |
| `v2.19.0-r1`, `v2.19.0-r2` | Documentation fixes or added details for NKP 2.19.0. |
| `v2.19.1` | Documentation for the NKP 2.19.1 patch release. |

To publish a release:

```bash
git tag -a v2.19.0 -m "Documentation for NKP 2.19.0"
git push origin v2.19.0
gh release create v2.19.0 --generate-notes
```

Use `--prerelease` for releases whose guides are not yet tested with that NKP
version.

## GitHub Pages

The MkDocs site is published to
[GitHub Pages](https://jlnhnng.github.io/nkp-field-docs/) by
`.github/workflows/docs.yml`.

Every push to `main` runs a strict MkDocs build, uploads the generated `site/`
artifact, and deploys it through the `github-pages` environment.

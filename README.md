# NKP Field Docs

Practical architecture and installation guidance for Nutanix Kubernetes Platform
engineers. The site explains NKP in plain language and captures field experience;
it does not replace Nutanix support, release notes, or compatibility information.

## Documentation

The documentation is built with [MkDocs](https://www.mkdocs.org/) +
[Material](https://squidfunk.github.io/mkdocs-material/).

- Architecture pages live in `docs/architecture/`.
- Installation guides and the OpenTofu bootstrap module live in `docs/install/`.
- Upgrade guides live directly in `docs/upgrades/`.

```bash
pip install -r requirements.txt
mkdocs serve   # http://127.0.0.1:8000
```

## GitHub Pages

The MkDocs site is published to
[GitHub Pages](https://jlnhnng.github.io/nkp-field-docs/) by
`.github/workflows/docs.yml`.

Every push to `main` runs a strict MkDocs build, uploads the generated `site/`
artifact, and deploys it through the `github-pages` environment.

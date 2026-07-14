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

## Cloudflare Workers

The MkDocs site is deployed as
[Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/).
`wrangler.jsonc` publishes the generated `site/` directory.

The GitHub Actions workflow builds and deploys every push to `main`. Configure
these repository secrets before the first deployment:

- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_API_TOKEN` with permission to deploy Workers

To deploy from a local workstation:

```bash
mkdocs build --strict --site-dir site
npx wrangler@latest deploy
```

After assigning a `workers.dev` or custom domain, add its canonical URL as
`site_url` in `mkdocs.yml`.

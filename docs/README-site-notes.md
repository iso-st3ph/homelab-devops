# Docs
Planned diagram of workflow (Terraform → Ansible → Docker → CI).

# How to run locally & deploy IsoVault site

## Local preview

```bash
mkdocs serve
```

Open http://127.0.0.1:8000 in your browser to preview the site.

## Deploy to GitHub Pages

```bash
mkdocs gh-deploy --clean --force -b gh-pages
```

## Rollback

If anything fails, checkout `main` and run:

```bash
mkdocs serve
```

Site should build and serve as before.

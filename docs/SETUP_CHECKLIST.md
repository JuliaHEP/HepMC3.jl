# Documentation Deployment Setup Checklist

Quick checklist for setting up documentation deployment:

## Pre-Deployment Checklist

- [ ] Repository is public (or you have GitHub Pro/Team for private repos)
- [ ] You have admin access to the repository
- [ ] The `.github/workflows/docs.yml` file exists and is committed
- [ ] The `docs/make.jl` file has the correct repository URL

## SSH Key Setup

- [ ] Generated SSH key pair (`ssh-keygen -t ed25519`)
- [ ] Added public key as a **Deploy Key** with **write access** enabled
- [ ] Added private key as GitHub Secret named `DOCUMENTER_KEY`

## GitHub Pages Setup

- [ ] Enabled GitHub Pages in repository Settings → Pages
- [ ] Source set to: **Deploy from a branch**
- [ ] Branch set to: `gh-pages`
- [ ] Folder set to: `/ (root)`

## First Deployment

- [ ] Pushed a commit to `main` or `master` branch
- [ ] Checked Actions tab - workflow is running
- [ ] Workflow completed successfully
- [ ] Documentation is accessible at `https://[username].github.io/HepMC3.jl/`

## Verification

After first deployment, verify:

- [ ] Dev documentation: `https://[username].github.io/HepMC3.jl/dev/`
- [ ] Stable documentation: `https://[username].github.io/HepMC3.jl/stable/`
- [ ] Navigation works correctly
- [ ] All pages load without errors

## Notes

- The workflow automatically deploys on pushes to `main`/`master`
- Tagged versions (e.g., `v0.1.0`) will create versioned documentation
- Documentation builds may take 5-10 minutes
- GitHub Pages updates can take a few minutes after workflow completion

## Need Help?

See `docs/DEPLOYMENT.md` for detailed instructions and troubleshooting.


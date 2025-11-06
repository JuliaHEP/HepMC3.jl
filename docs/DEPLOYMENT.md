# Documentation Deployment Guide

This guide explains how to deploy the HepMC3.jl documentation to GitHub Pages using GitHub Actions.

## Prerequisites

1. A GitHub repository (e.g., `JuliaHEP/HepMC3.jl`)
2. Admin access to the repository
3. The repository must be public (or you need GitHub Pro/Team for private repos)

## Setup Steps

### Step 1: Generate a SSH Deploy Key

The documentation deployment requires a SSH key to push to the `gh-pages` branch. Generate one as follows:

1. **Generate a new SSH key pair** (on your local machine):

```bash
ssh-keygen -t ed25519 -C "hepmc3-docs-deploy" -f ~/.ssh/hepmc3_docs_deploy
```

- When prompted for a passphrase, you can leave it empty (press Enter twice)
- This creates two files:
  - `~/.ssh/hepmc3_docs_deploy` (private key)
  - `~/.ssh/hepmc3_docs_deploy.pub` (public key)

2. **Add the public key to your repository**:

   - Go to your repository on GitHub
   - Navigate to **Settings** → **Deploy keys**
   - Click **Add deploy key**
   - Title: `Documentation Deploy Key`
   - Key: Copy the contents of `~/.ssh/hepmc3_docs_deploy.pub`
   - ✅ Check **Allow write access** (important!)
   - Click **Add key**

3. **Add the private key as a GitHub Secret**:

   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `DOCUMENTER_KEY`
   - Value: Copy the contents of `~/.ssh/hepmc3_docs_deploy` (the private key, including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)
   - Click **Add secret**

### Step 2: Enable GitHub Pages

1. Go to **Settings** → **Pages**
2. Under **Source**, select:
   - Source: **Deploy from a branch**
   - Branch: `gh-pages`
   - Folder: `/ (root)`
3. Click **Save**

### Step 3: Verify Workflow Configuration

The workflow file (`.github/workflows/docs.yml`) is already configured. It will:

- Build the documentation on pushes to `main`/`master` and on version tags
- Deploy to the `gh-pages` branch
- Create versioned documentation (stable, dev, and tagged versions)

### Step 4: Test the Deployment

1. **Push a commit to the main branch**:

```bash
git add .
git commit -m "Update documentation"
git push origin main
```

2. **Check the Actions tab**:
   - Go to the **Actions** tab in your GitHub repository
   - You should see a "Documentation" workflow running
   - Wait for it to complete (usually 5-10 minutes)

3. **Verify the deployment**:
   - Once the workflow completes, go to **Settings** → **Pages**
   - Your documentation should be available at:
     - `https://[username].github.io/HepMC3.jl/` (or your organization's domain)

## Documentation URLs

After deployment, your documentation will be available at:

- **Latest (dev)**: `https://[username].github.io/HepMC3.jl/dev/`
- **Stable**: `https://[username].github.io/HepMC3.jl/stable/`
- **Tagged versions**: `https://[username].github.io/HepMC3.jl/v0.1.0/` (for tag v0.1.0)

## Troubleshooting

### Workflow Fails with "Permission Denied"

- Ensure the deploy key has **write access** enabled
- Verify the `DOCUMENTER_KEY` secret is correctly set (must include the full private key)

### Documentation Not Appearing

- Check that GitHub Pages is enabled and pointing to the `gh-pages` branch
- Wait a few minutes after the workflow completes (GitHub Pages can take time to update)
- Check the Actions logs for any errors

### Build Errors

- Ensure all dependencies are listed in `docs/Project.toml`
- Check that the package builds successfully (the docs workflow builds the package first)
- Review the workflow logs in the Actions tab

### Version Detection Issues

- The workflow uses `fetch-depth: 0` to get full git history for version detection
- Ensure you're using semantic versioning tags (e.g., `v0.1.0`)

## Manual Deployment (Alternative)

If you prefer to deploy manually instead of using GitHub Actions:

```bash
# Install dependencies
julia --project=docs -e "using Pkg; Pkg.instantiate()"

# Build and deploy
julia --project=docs docs/make.jl
```

However, using GitHub Actions is recommended as it automatically deploys on every push.

## Additional Resources

- [Documenter.jl Documentation](https://juliadocs.github.io/Documenter.jl/stable/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)


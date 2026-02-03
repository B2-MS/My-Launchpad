# Send It Instructions

Complete workflow for building, documenting, and publishing My Launchpad.

---

## Quick Reference

```bash
# 1. Rebuild & deploy
./rebuild.sh

# 2. Update docs (see update-docs.md)

# 3. Verify documentation
./verify-docs.sh

# 4. Create DMG
./create-dmg.sh

# 5. Push to GitHub
git add -A && git commit -m "Release vX.X.X - description" && git push
```

---

## Step-by-Step Workflow

### 1. 🔨 Rebuild & Deploy

```bash
./rebuild.sh
```

### 2. 📝 Update Documentation

See [update-docs.md](update-docs.md) for:
- Markdown files checklist
- Chat history prompt
- Prompts used prompt
- Version badge format
- Release notes template

### 3. ✅ Verify Documentation

```bash
./verify-docs.sh
```

**All checks must pass before proceeding!**

### 4. 💿 Create DMG

```bash
./create-dmg.sh
```

### 5. 📤 Push to GitHub

```bash
git add -A && git commit -m "Release vX.X.X - description" && git push
```

### 6. 🚀 Create GitHub Release (Optional)

```bash
gh release create vX.X.X "releases/My Launchpad Installer.dmg" --title "My Launchpad vX.X.X" --generate-notes
```

---

## Checklist

- [ ] `./rebuild.sh` - App builds and launches
- [ ] Documentation updated (see [update-docs.md](update-docs.md))
- [ ] `./verify-docs.sh` - **ALL CHECKS PASS**
- [ ] `./create-dmg.sh` - DMG created
- [ ] `git push` - Changes pushed to GitHub
- [ ] GitHub Release published (optional)

---

## Notes

- The `gh` command requires GitHub CLI (`brew install gh`)
- First time use requires authentication: `gh auth login`
- Use `--generate-notes` to auto-generate release notes from commits

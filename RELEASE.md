# Releasing a New Version of Steply

This document is the authoritative guide for cutting a Steply release.
Most steps are automated by GitHub Actions — your job is to push the tag.

---

## What is automated vs. manual

| Step | Who does it |
|------|------------|
| Sync `VERSION.txt` to the tag (before build, so the zip has the right version inside) | CI (on tag push) |
| Build no-JRE zip | CI (on tag push) |
| Create GitHub Release and attach zip | CI (on tag push) |
| Create PR to update `install.sh`, `install_mac_arm.sh`, and `VERSION.txt` | CI (on tag push) |
| Integration test against the new zip | CI (on tag push) |
| Integration test via `curl` (real user one-liner) | CI (on release PR merge to main) |
| Merge the release PR | **You** |
| Build + upload the ARM Mac bundled-JRE zip | **You** (if distributing that package) |

---

## Version format

```
YYYYMMDD.nn
```

Examples: `20260424.01`, `20260424.02` (second release same day)

---

## Step-by-step release process

### Step 1 — Push a git tag (triggers everything)

```bash
git tag YYYYMMDD.nn
git push origin YYYYMMDD.nn
```

This single command triggers the following CI jobs automatically:

1. **Sync VERSION.txt** — CI patches `VERSION.txt` to match the tag before building, so `steply -v` always reports the correct version
2. **Build** — compiles the project and produces `steply-YYYYMMDD.nn-no-jre.zip`
3. **GitHub Release** — creates a release named `YYYYMMDD.nn` and attaches the zip
4. **Integration test** — installs from the new zip on a fresh Ubuntu runner and runs `steply -v`
5. **Auto PR** — opens a PR that updates `VERSION` in `scripts/install.sh`, `scripts/install_mac_arm.sh`, and `VERSION.txt` on main

You can watch all of this at:
`https://github.com/QABEES/steply/actions`

- Before auto-PR merge (after release tag push):
<img width="800" height="480" alt="image" src="https://github.com/user-attachments/assets/cc90ba55-90f8-400f-8fbd-e02e158ac650" />

- After auto-PR merge (after release tag push):
<img width="800" height="480" alt="image" src="https://github.com/user-attachments/assets/739a6aa1-3587-4d21-8bec-911789040abd" />

---

### Step 2 — Review and merge the auto PR

Once CI is green, open the auto-created PR and merge it.

After merge, the install one-liner:
```bash
curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
```
will deliver the new version to users.

Merging also triggers a final CI job (`integration-test-curl`) that runs exactly the above
`curl | bash` on a fresh Ubuntu runner to confirm the end-to-end user experience is working.

---

### Step 3 (if applicable) — Upload the ARM Mac bundled-JRE zip

The no-JRE zip is built and uploaded automatically. The ARM Mac zip (which bundles a local JRE
for users who do not have Java installed) must be built locally and uploaded manually.

**Build it:**

```bash
./scripts/build-distribution-local-jre.sh \
  /path/to/jdk17      \   # e.g. ~/.sdkman/candidates/java/17.0.17-tem
  /tmp/steply-dist
```

The zip will be at `/tmp/steply-YYYYMMDD.nn.zip`. Rename it to match the release if needed.

**Upload it:**

1. Go to `https://github.com/QABEES/steply/releases/tag/YYYYMMDD.nn`
2. Click **Edit release**
3. Drag and drop the zip into the assets section
4. Click **Update release**

---

## Troubleshooting

### Integration test fails with "UnsupportedClassVersionError"

The runner picked up a Java version older than 17. This should not happen on GitHub-hosted runners
(Java 17 is pre-installed), but if it does, check that `JAVA_HOME` is not pinned to an older JDK
in your workflow environment.

### "Release already exists" error on tag push

A release for this tag was created in a previous attempt. Either delete the release and re-push
the tag, or increment the patch number (`.02`, `.03`, ...) and push a new tag.

### Auto PR was not created

Check the Actions run for the tag. The PR step requires `contents: write` and `pull-requests: write`
permissions, which are set in `ci.yml`. If it fails, confirm that the `GITHUB_TOKEN` has not been
restricted in repository settings.

### `steply -v` shows wrong version

This was a known issue when `VERSION.txt` was updated manually and could fall out of sync with the
tag. It is now fixed — CI patches `VERSION.txt` to match the tag before building, so the file
bundled inside the zip is always correct.

---

## Quick reference

```bash
# Entire release in one command
git tag YYYYMMDD.nn && git push origin YYYYMMDD.nn
# then merge the auto PR on GitHub
```

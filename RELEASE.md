# Releasing a New Version of Steply

This document is the authoritative guide for cutting a Steply release.
Most steps are automated by GitHub Actions — your job is to push the right commits and tag.

---

## What is automated vs. manual

| Step | Who does it |
|------|------------|
| Build no-JRE zip | CI (on tag push) |
| Create GitHub Release and attach zip | CI (on tag push) |
| Create PR to update `VERSION` in `install.sh` and `install_mac_arm.sh` | CI (on tag push) |
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

### Step 1 — Bump VERSION.txt on main

Edit `VERSION.txt` so it contains the new version:

```
steply.version=YYYYMMDD.nn
build.date=PLACEHOLDER
```

Commit and push to main:

```bash
git add VERSION.txt
git commit -m "chore: bump version to YYYYMMDD.nn"
git push origin main
```

Wait ~2 minutes for the CI build job to go green. This validates the code is healthy before you tag it.

---

### Step 2 — Push a git tag (triggers the release)

```bash
git tag YYYYMMDD.nn
git push origin YYYYMMDD.nn
```

This single command triggers the following CI jobs automatically:

1. **Build** — compiles the project and produces `steply-YYYYMMDD.nn-no-jre.zip`
2. **GitHub Release** — creates a release named `YYYYMMDD.nn` and attaches the zip
3. **Integration test** — installs from the new zip on a fresh Ubuntu runner and runs `steply -v`
4. **Auto PR** — opens a PR titled `chore: update two install scripts for release YYYYMMDD.nn` that bumps `VERSION` in both `scripts/install.sh` and `scripts/install_mac_arm.sh`

You can watch all of this at:
`https://github.com/QABEES/steply/actions`

- Before auto-PR merge(after release tag push):
<img width="800" height="480" alt="image" src="https://github.com/user-attachments/assets/cc90ba55-90f8-400f-8fbd-e02e158ac650" />


- After auto-PR merge(after release tag push):
<img width="800" height="480" alt="image" src="https://github.com/user-attachments/assets/739a6aa1-3587-4d21-8bec-911789040abd" />

---

### Step 3 — Review and merge the auto PR

Once CI is green, open the auto-created PR and merge it.

After merge, the install one-liner:
```bash
curl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
```
will deliver the new version to users.

Merging also triggers a final CI job (`integration-test-curl`) that runs exactly the above
`curl | bash` on a fresh Ubuntu runner to confirm the end-to-end user experience is working.

---

### Step 4 (if applicable) — Upload the ARM Mac bundled-JRE zip

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

### Integration test tested the wrong (old) zip

This was a known bug: the integration test used to run against the old `VERSION` because the
release PR had not yet been merged. It is now fixed — the CI patches `VERSION` in `install.sh`
to match the tag before running the test.

---

## Quick reference

```bash
# Full release in three commands
git add VERSION.txt
git commit -m "chore: bump version to YYYYMMDD.nn"
git push origin main
# wait for green CI
git tag YYYYMMDD.nn && git push origin YYYYMMDD.nn
# then merge the auto PR on GitHub
```

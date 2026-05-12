# MailHogPlus Knowledge Base

## Project
- Fork base: `mailhog/MailHog`
- Local repo path: `C:\Users\dan\Documents\integrate-it\MailHogPlus`
- Goal direction: keep MailHog simplicity, add team-focused development features.

## Decisions
- 2026-05-12: First branding pass started.
- Display-facing `MailHog` references were renamed to `MailHogPlus` across core docs and runtime text.
- Go import paths and upstream dependency paths were kept on `mailhog/*` to avoid breaking builds.

## Work Log
- Updated CLI version output text in `main.go` to `MailHogPlus version: ...`.
- Updated `README.md` and docs under `docs/` for `MailHogPlus` naming.
- Updated API title text in:
  - `docs/APIv2/swagger-2.0.yaml`
  - `docs/APIv2/swagger-2.0.json`
- Updated SMTP `Received` header product tag in:
  - `vendor/github.com/mailhog/data/message.go`
- Updated packaging display text in:
  - `Dockerfile`
  - `snapcraft.yaml`
- Updated legal/project attribution and install guidance:
  - `README.md` now explicitly states fork relationship to `mailhog/MailHog`.
  - Replaced misleading package-manager/upstream install instructions with source-build instructions for this fork.
  - Updated `docs/BUILD.md` and `docs/DEPLOY.md` to align with fork-local build/deploy flows.

## Known Follow-up
- Binary/executable naming is still mixed in tooling (`MailHog` command is still used in build/runtime paths).
- If you want the executable/package names fully changed to `MailHogPlus`, that should be done as a dedicated step (module paths, release/build pipeline, package names, and install docs).

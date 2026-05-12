Building MailHogPlus
================

MailHogPlus is a fork of `mailhog/MailHog`. Keep upstream attribution and MIT license notices intact in derivative work.

MailHogPlus is built using `make`, and using [this Makefile](../Makefile).

Build this fork from source:

```bash
git clone <your-fork-url>
cd MailHogPlus
make deps
go build -o MailHogPlus .
```

### Why do I need a Makefile?

MailHogPlus has HTML, CSS and Javascript assets which need to be converted
to a go source file using [go-bindata](https://github.com/jteeuwen/go-bindata).

This must happen before running `go build` or `go install` to avoid compilation
errors (e.g., `no buildable Go source files in MailHog-UI/assets`).

### go generate

The build should be updated to use `go generate` (added in Go 1.4) to
preprocess static assets into go source files.

However, this will break backwards compatibility with Go 1.2/1.3.

### Building a release

Releases are built using [gox](https://github.com/mitchellh/gox).

Run `make release` to cross-compile for all available platforms.

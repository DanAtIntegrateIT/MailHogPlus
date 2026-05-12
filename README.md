MailHogPlus [ ![Download](https://img.shields.io/github/release/mailhog/MailHog.svg) ](https://github.com/mailhog/MailHog/releases/tag/v1.0.0) [![GoDoc](https://godoc.org/github.com/mailhog/MailHog?status.svg)](https://godoc.org/github.com/mailhog/MailHog) [![Build Status](https://travis-ci.org/mailhog/MailHog.svg?branch=master)](https://travis-ci.org/mailhog/MailHog)
=========

This repository is a `MailHog` fork branded as `MailHogPlus` for additional IT development team workflows.
It includes modifications on top of the upstream `mailhog/MailHog` project.

Inspired by [MailCatcher](https://mailcatcher.me/), easier to install.

* Download and run MailHogPlus
* Configure your outgoing SMTP server
* View your outgoing email in a web UI
* Release it to a real mail server

Built with Go - MailHogPlus runs without installation on multiple platforms.

### Overview

MailHogPlus is an email testing tool for developers:

* Configure your application to use MailHogPlus for SMTP delivery
* Route SMTP usernames into mailbox folders for team-based inbox workflows
* Work in a professional multi-pane UI with switchable layouts and resizable panes
* View messages in the web UI (HTML, plain text, source, attachments, MIME), or retrieve them with the JSON API
* Score each email with RAG quality status (Red/Amber/Green) before sending
* Persist messages with retention controls from the settings page
* Optionally release messages to real SMTP servers for delivery

### Installation

Install from source in this fork:

```bash
git clone <your-fork-url>
cd MailHogPlus
make deps
go build -o MailHogPlus .
```

Run:

```bash
./MailHogPlus
```

If you use Docker, build from this repository's [Dockerfile](Dockerfile).

### Dev vs Production Dependencies

`go.mod` is production-oriented and points at `github.com/DanAtIntegrateIT/*` modules.

For local development from checked out sibling repositories:

* `../MailHogPlus-Server`
* `../MailHogPlus-UI`

use:

```bash
make combined-dev
```

For production-style dependency resolution and vendoring, use:

```bash
make combined
make vendor-prod
```

### Configuration

Check out how to [configure MailHogPlus](/docs/CONFIG.md), or use the default settings:
  * the SMTP server starts on port 1025
  * the HTTP server starts on port 8025
  * in-memory message storage

The repository includes `mailhogplus-settings.example.json` as a template.
Your local runtime file `mailhogplus-settings.json` is intentionally ignored by git.

### Features

See [MailHogPlus libraries](docs/LIBRARIES.md) for a list of MailHogPlus client libraries.

* ESMTP server implementing RFC5321
* Support for SMTP AUTH (RFC4954) and PIPELINING (RFC2920)
* Professional multi-view workspace (folders + list + preview) with switchable layouts
* Draggable split panes for list/preview sizing
* Sidebar with scrollable folder area and fixed system menu (connection, settings, about)
* Folder routing by SMTP username, preserving folder case with case-insensitive matching
* Configurable default inbox folders and optional "Force default inbox only" enforcement
* Favorites with quick filtering
* Read/unread tracking with keyboard shortcuts (Up/Down selection, Space toggle)
* Attachment paperclip indicators in the list and dedicated Attachments tab with download-all
* MIME tab for full MIME/part inspection
* Email quality scoring and RAG tab with actionable hints
* Full message view in a separate browser window
* Web interface to view messages (plain text, HTML, source, attachments, MIME)
* Supports RFC2047 encoded headers
* Real-time updates using EventSource
* Release messages to real SMTP servers
* Chaos Monkey for failure testing
* See [Introduction to Jim](/docs/JIM.md) for more information
* HTTP API to list, retrieve and delete messages
* See [APIv1](/docs/APIv1.md) and [APIv2](/docs/APIv2.md) documentation for more information
* [HTTP basic authentication](docs/Auth.md) for MailHogPlus UI and API
* Multipart MIME support
* Download individual MIME parts
* Configurable retention and storage mode (memory-only or maildir persistence)
* MongoDB and file-based storage support
* Lightweight and portable
* No installation required

#### sendmail

[mhsendmail](https://github.com/mailhog/mhsendmail) is a sendmail replacement for MailHogPlus.

It redirects mail to MailHogPlus using SMTP.

You can also use `MailHogPlus sendmail ...` instead of the separate mhsendmail binary.

Alternatively, you can use your native `sendmail` command by providing `-S`, for example:

```bash
/usr/sbin/sendmail -S mail:1025
```

For example, in PHP you could add either of these lines to `php.ini`:

```
sendmail_path = /usr/local/bin/mhsendmail
sendmail_path = /usr/sbin/sendmail -S mail:1025
```

#### Web UI

![Screenshot of MailHogPlus web interface](docs/MailHogPlus-UI-2026.png "MailHogPlus web interface")

### Contributing

MailHogPlus is a fork of [mailhog/MailHog](https://github.com/mailhog/MailHog).
The original project lineage includes [ian-kent/MailHog](https://github.com/ian-kent/MailHog), which was born out of [M3MTA](https://github.com/ian-kent/M3MTA).

Clone this repository and run `make deps`.

See the [Building MailHogPlus](/docs/BUILD.md) guide.

Requires Go 1.4+ to build.

Run tests using ```make test``` or ```goconvey```.

If you make any changes, run ```go fmt ./...``` before submitting a pull request.

### Licence

Copyright ©‎ 2014 - 2017, Ian Kent (http://iankent.uk)

Released under MIT license, see [LICENSE](LICENSE.md) for details.

This fork retains upstream copyright and license notices and adds MailHogPlus-specific changes.
Additional fork copyright: (c) 2026 Integrate IT.

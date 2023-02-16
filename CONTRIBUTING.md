<!--
SPDX-FileCopyrightText: 2023 Ian2020 <https://github.com/Ian2020>

SPDX-License-Identifier: CC-BY-SA-4.0

Monica reminder is a BASH script that will takeover the emailing of reminders
for a Monica instance if you are experiencing problems.

For full copyright information see the AUTHORS file at the top-level
directory of this distribution or at
[AUTHORS](https://github.com/Ian2020/monica_reminder/AUTHORS.md)

This work is licensed under the Creative Commons Attribution 4.0 International
License. You should have received a copy of the license along with this work.
If not, visit http://creativecommons.org/licenses/by/4.0/ or send a letter to
Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
-->

# Contributing

Feedback and contribution are welcome.

## Table of Contents

<!-- vim-markdown-toc GitLab -->

* [General Information](#general-information)
* [Contributions](#contributions)
  * [Developer Certificate of Origin (DCO)](#developer-certificate-of-origin-dco)
  * [License](#license)
  * [Code Changes](#code-changes)
  * [Releasing](#releasing)
* [Attribution](#attribution)

<!-- vim-markdown-toc -->

## General Information

Please provide ideas via issues or pull requests to our GitLab repository:
[https://github.com/Ian2020/monica_reminder](https://github.com/Ian2020/monica_reminder).

Our documentation consists of the following files in the repository:

* AUTHORS.md
* CHANGELOG.md
* CODE_OF_CONDUCT.md
* CONTRIBUTING.md (this file)
* GOVERNANCE.md
* README.md
* LICENSES directory

## Contributions

Please note that this project is released with a Contributor Code of Conduct. By
participating in this project you agree to abide by its terms. We use the
[Contributor Convenant version
2.0](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html) a
copy of which is available in the repository: CODE_OF_CONDUCT.md. This code is
the same as used by the Linux kernel and many other projects.

### Developer Certificate of Origin (DCO)

All contributions must agree to the Developer Certificate of Origin (DCO) to
certify that you wrote or otherwise have the right to submit code or
documentation to the project. We use the same DCO as many other projects: the
[Developer Certificate of Origin version
1.1](https://developercertificate.org/):

> Developer Certificate of Origin
> Version 1.1
>
> Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
> 1 Letterman Drive
> Suite D4700
> San Francisco, CA, 94129
>
> Everyone is permitted to copy and distribute verbatim copies of this
> license document, but changing it is not allowed.
>
>
> Developer's Certificate of Origin 1.1
>
> By making a contribution to this project, I certify that:
>
> (a) The contribution was created in whole or in part by me and I
> have the right to submit it under the open source license
> indicated in the file; or
>
> (b) The contribution is based upon previous work that, to the best
> of my knowledge, is covered under an appropriate open source
> license and I have the right under that license to submit that
> work with modifications, whether created in whole or in part
> by me, under the same open source license (unless I am
> permitted to submit under a different license), as indicated
> in the file; or
>
> (c) The contribution was provided directly to me by some other
> person who certified (a), (b) or (c) and I have not modified
> it.
>
> (d) I understand and agree that this project and the contribution
> are public and that a record of the contribution (including all
> personal information I submit with it, including my sign-off) is
> maintained indefinitely and may be redistributed consistent with
> this project or the open source license(s) involved.

Simply submitting a contribution implies this agreement however for larger
contributions please include a "Signed-off-by" tag in every patch (this tag is a
conventional way to confirm that you agree to the DCO). You can do this with git
commit --signoff (the -s flag is a synonym for --signoff).

Another way to do this is to write the following at the end of the commit
message, on a line by itself separated by a blank line from the body of the
commit:

```text
Signed-off-by: YOUR NAME <YOUR.EMAIL@EXAMPLE.COM>
```

You can signoff by default in this project by creating a file (say
"git-template") that contains some blank lines and the signed-off-by text above;
then configure git to use that as a commit template. For example:

```text
git config commit.template ~/cii-best-practices-badge/git-template
```

It's not practical to fix old contributions in git, so if one is forgotten, do
not try to fix them. We presume that if someone sometimes used a DCO, a commit
without a DCO is an accident and the DCO still applies.

### License

All (new) contributed material must be released under the GPLv3 or later. A copy
of the license is included in the repository, see the LICENSES directory. All
new contributed material that is not executable, including all text when not
executed, is also released under the [Creative Commons Attribution ShareAlike
4.0 International (CC BY-SA
4.0)](https://creativecommons.org/licenses/by-sa/4.0/) license.

### Code Changes

* When reusing components they MUST have a license compatible with the license of
  this software.
* Test coverage is required except in case of trivial changes
* Linting:
  * BASH code should be clean with `shellcheck`
  * Markdown should be clean with `mdl`

Prerequisites:

* Build file uses [ninja](https://ninja-build.org/).
* Tests use [bats](https://github.com/bats-core/bats-core)

Updating dependancies:

* Both above tools are usually managed through system package manager and
  therefore just keeping your system up-to-date is enough.
* We have dependencies on
  [bats-assert](https://github.com/bats-core/bats-assert) and
  [bats-support](https://github.com/bats-core/bats-support) managed via git
  submodules.
  * Check current versions `git submodule`
  * To update each individually:
    * `cd test/test_helper/bats-assert/ ; git checkout TAG`
    * `cd test/test_helper/bats-support/ ; git checkout TAG`

Testing:

We have a set of growing unit tests as part of the build.

To test against your own live system be sure to use dryrun:

```bash
CONTAINER=monica DRYRUN=true ./monica_reminder
```

Optionally use `LOGDIR=-` to get logs to stdout.

### Releasing

In the following `<VERSION>` should be replaced with the new version number
prepended with a `v`, e.g. `v1.0.0`.

* Update [CHANGELOG.md](CHANGELOG.md)

  The 'Unreleased' entry at the top of `CHANGELOG.md` should already
  enumerate the significant updates to the new version. If not update it, retitle
  it with the version number and date, then create a new empty 'Unreleased' entry.
  At the bottom add a reference to the release tag.

* Update copyright years if applicable

  Run `copier update` and update the copyright year. You can use a range here so
  long as you have a statement explaining this use in your README. You may want
  to re-apply your copyright headers to files now and check REUSE compliance to
  ensure all updated.

* Commit, tag and push

  Commit these changes (including the `CHANGELOG.md` changes) with the message
  `monica_reminder <VERSION>`

  Create a new annotated tag with:

  ```bash
  git tag -a -e -F <(sed "s/^#\+ //g" CHANGELOG.md) <VERSION>
  ```

  Include the `CHANGELOG.md` notes corresponding to the new version as the
  tag annotation, except the first line should be:

  ```text
  monica_reminder <VERSION> - YYYY-MM-DD
  ```

  Push the new version commit and tag to GitLab via the following:

  ```bash
  git push --follow-tags
  ```

* Create a GitHub release - for now we're doing this through the website.
  * Select the tag you just pushed
  * Title: `monica_reminder <VERSION>`
  * Take release notes straight from the CHANGELOG
  * Include `monica_reminder` as a release asset so that it can be installed
    by [bin](https://github.com/marcosnils/bin).

## Attribution

Parts of this text are based on the contribution guide of the Core
Infrastructure Initiative's
[Best Practices Badge
Project](https://github.com/coreinfrastructure/best-practices-badge/blob/master/CONTRIBUTING.md),
licensed under the [Creative Commons Attribution 3.0 International (CC BY 3.0)
license or later.](https://creativecommons.org/licenses/by/3.0/):

Specifically the following sections were copied and adapted: the introduction,
'General information', 'Developer Certificate of Origin (DCO)', 'License',
'Vulnerability Reporting' and 'Code Changes'.

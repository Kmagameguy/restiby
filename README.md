# Restiby

Restiby (restic + ruby) is a collection of ruby-based helper utilities that make working with [restic backups][restic-backups] and restores easier.

Inspiration comes from:
  - [autorestic][autorestic], which, at time of writing (July 2025) may be a dormant project?  I also prefer ruby over golang.
  - This blog post, [Backup with Restic][backup-with-restic] by [Thomas Queste][tomsquest], who also maintains a pretty fabulous `docker-radicale` project.
  - A general desire to automate restic backups for multiple machines/locations with built-in integrity checking.  Restic is a fabulous and flexible tool, but the flexibility comes at the expense of a somewhat obtuse CLI tool, IMO.  E.g. either specifying the target repository and password(s) through cli flags for EVERY command or through env variables (woof).

## Prerequisites
1. The `restic` binary installed and in your `PATH`.
1. A modern version of ruby (code was originally developed using the latest at time of writing, ruby 3.4.5).

Note that these utilities have only been tested on Linux. YMMV on macOS, or, *shudders*, Windows...

## Getting Started
1. Clone this repo
1. Make copies of `.restiby.exclude.example` and `restiby.yml.example` files.  Fill out each one with details, following the templated options.
1. Start making backups!  Running the command below will take care of the following tasks:
  - Check for and install any update for the restic binary (only available on Restic version 0.18.0 and newer)
  - Initialize the restic repository, if one doesn't exist already at the location specified in your `restiby.yml` file
  - Run a new backup
  - Verify the integrity of the backup
  - Print out a diff of the changes included in the new snapshot
  - Notify any configured clients on success (e.g. Discord or Healthchecks.io)

```bash
./restiby --action backup
```

You can also add a symlink to `/usr/local/bin/` by running the included install script:

```bash
bin/install
```

This will let you call the restiby script from anywhere on your system:

```
cd $HOME
restiby --action backup
```

To uninstall it, just delete the symlink from `/usr/local/bin`.

## Notes
1. Depending on which directories you're trying to access, you may get permission errors.  Restic's documentation provides a guide which explains how to allow the restic binary to perform rootless backups:
    - [Backing up your system without running restic as root][backup-without-root]
1. This project is still WIP.  Some of the features that I plan to develop are listed below.
1. In designing this repo I want the dependencies to remain lightweight.  Therefore, aside from dev dependencies (see below) I've avoided relying on gems and libraries that aren't part of the ruby core library.  If you just want to run this scripts all you need is a base ruby install.

## Developer Setup & Contributing
All you need to get started is a base ruby install:
1. Run `bin/dev-setup` to bootstrap the development environment.  This will install bundler if it's missing as well as the ruby gems specified in the project's `Gemfile`.
1. Once dependencies are installed you're good to go.  You can run `bin/dev-test` as a litmus test -- if the tests all pass then your environment is good to go.
1. Any time you pull new changes from the main branch you'll want to run `dev-update` to ensure you also pull in any new dependencies.  `dev-update` exists just for convenience/clarity -- it just calls `dev-setup` under the hood.

## Roadmap
Desired features are listed below.  Note that they are in no particular order of importance.
- [ ] Handle restoring from snapshot(s)
- [ ] Cloud-based backups
- [ ] E-mail Notifications
- [ ] Snapshot browsing/content management
- [ ] Logo/Mascot
- [ ] Auto-generate secure repository passkeys

## Disclaimer
This project is still in early development, so no warranties can be made regarding its safety or the integrity of the backups it creates.  Use at your own risk.  Test and validate your backups early and often!  This project is not affiliated with or endorsed by the restic project.

[restic-backups]:https://restic.readthedocs.io
[autorestic]:https://github.com/cupcakearmy/autorestic
[backup-with-restic]:https://www.tomsquest.com/blog/2024/12/backup-restic-setup/
[tomsquest]:https://github.com/tomsquest
[backup-without-root]:https://restic.readthedocs.io/en/stable/080_examples.html#backing-up-your-system-without-running-restic-as-root

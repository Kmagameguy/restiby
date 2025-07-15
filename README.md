# Restiby

Restiby (restic + ruby) is a collection of ruby-based helper utilities that make working with [restic backups][restic-backups] and restores easier.

Inspiration comes from:
  - [autorestic][autorestic], which, at time of writing (July 2025) may be a dormant project?  I also prefer ruby over golang.
  - This blog post, [Backup with Restic][backup-with-restic] by [Thomas Queste][tomsquest], who also maintains a pretty fabulous `docker-radicale` project.

## Prerequisites
1. The `restic` binary installed and in your `PATH`.
1. A modern version of ruby (code was originally developed using the latest at time of writing, ruby 3.4.4)

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
ruby restiby.rb --action backup
```

## Notes
1. Depending on which directories you're trying to access, you may get permission errors.  Restic's documentation provides a guide which explains how to allow the restic binary to perform rootless backups:
    - [Backing up your system without running restic as root][backup-without-root]
1. This project is still WIP.  Some of the features that I plan to develop are listed below.
1. In designing this repo I want the dependencies to remain lightweight.  Therefore I've avoided relying on gems and libraries that aren't part of the ruby core library.

## Roadmap
Desired features are listed below.  Note that they are in no particular order of importance.
- [ ] Handle restoring from snapshot(s)
- [ ] Cloud-based backups
- [ ] E-mail Notifications
- [ ] Snapshot browsing/content management
- [ ] Test Suite
- [ ] Logo/Mascot

[restic-backups]:https://restic.readthedocs.io
[autorestic]:https://github.com/cupcakearmy/autorestic
[backup-with-restic]:https://www.tomsquest.com/blog/2024/12/backup-restic-setup/
[tomsquest]:https://github.com/tomsquest
[backup-without-root]:https://restic.readthedocs.io/en/stable/080_examples.html#backing-up-your-system-without-running-restic-as-root

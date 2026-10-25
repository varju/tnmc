# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Legacy Perl CGI app (no framework) on Apache mod_cgid and MySQL. Pages are `*.cgi` scripts that `use lib '/tnmc'; use tnmc;`. Shared code lives in `tnmc/`.

## Environment

- There is no local dev environment. `rebuild.sh` builds the Docker image and redeploys production through an external compose repo (`~/dev/mars.varju.ca/pluto`). Never run it without asking.
- Paths are hard-coded to `/tnmc` (the container's DocumentRoot), so most scripts only work inside the container.
- DB settings are hard-coded in `tnmc/db.pm` (host `db`). The module connects as soon as it loads.
- There are no schema or migration files. Schema changes are dated `upgrade_db_*` subs in `db/upgrade_db.cgi`, run through the web.

## AutoLoader

- Subs after `__END__` in `tnmc/**/*.pm` are autoloaded from `/tnmc/auto`. `make` (AutoSplit) regenerates it, and the Docker build runs it.
- `tnmc.pm` uses `strict qw(vars subs)`, not full `strict`, because strict refs breaks the autoloader. Don't change it.

## Style

- Run `make tidy` (perltidy, 120 columns) before every commit.
- Match the existing style: `use strict; use warnings;` and `&pkg::sub()` calls.

## Tests

Three Test::Simple scripts in `test/tnmc/updater/*/`. They read `theatre.html` by relative path, so run each one from its own directory, for example `cd test/tnmc/updater/google && perl test_google.pl`. They need `/tnmc` on the include path.

#!/usr/bin/env python3
import argparse
from pathlib import Path

DESCRIPTION = "Deploy this repository to the given directory."
VERSION = "0.1"

MAPPINGS = {
    # TODO: Can't symlink bin/ directly to .local/bin/ because it will contain
    # items not version controlled in this repository.
    "bin/": "bin/",
    ".vim/": ".vim/",
    ".fzf/": ".fzf/",
    "rcfiles/bash_aliases": ".bash_aliases",
    "rcfiles/bashrc": ".bashrc",
    "rcfiles/gdbinit": ".gdbinit",
    "rcfiles/gitconfig": ".gitconfig",
    "rcfiles/pylintrc": ".pylintrc",
}


def parse_args():
    """Parse the commandline arguments."""
    parser = argparse.ArgumentParser(description=DESCRIPTION)
    parser.add_argument("--version", action="version", version=VERSION)
    parser.add_argument(
        "--verbose", "-v", action="store_true", default=False, help="Increase output verbosity"
    )
    parser.add_argument(
        "--dry-run", "-n", action="store_true", default=False, help="Dont do anything"
    )
    parser.add_argument("target", type=str, help="The directory to deploy this repository to.")
    return parser.parse_args()


def main(args):
    """Deploy this repository to the given directory."""
    if not Path(args.target).exists():
        print(args.target, "does not exist! Cannot deploy.")
        return

    for src, dest in MAPPINGS.items():
        src = Path(src).resolve()
        dest = Path(args.target).joinpath(dest)

        if args.verbose or args.dry_run:
            print("symlinking", dest, "->", src)

        if not args.dry_run:
            if dest.exists():
                print(dest, "exists! Not symlinking.")
            else:
                dest.symlink_to(src)


if __name__ == "__main__":
    main(parse_args())

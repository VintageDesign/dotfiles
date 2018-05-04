#!/usr/bin/env python3
import argparse
import os
from datetime import datetime
from pathlib import Path
from subprocess import call


def parse_args():
    """
        Defines and parses commandline arguments for note-taking script.
    """
    DESCRIPTION = "A small script to facilitate taking, searching, and organizing notes."
    VERSION = "0.1"

    parser = argparse.ArgumentParser(description=DESCRIPTION)
    group = parser.add_mutually_exclusive_group()

    parser.add_argument('--version', action='version', version=VERSION)
    group.add_argument('-s', '--search',
                       help='A quoted string regular expression to search for.',
                       type=str)
    group.add_argument('--todo',
                       action='store_true',
                       default=False,
                       help='Open the TODO list.')
    group.add_argument('--month',
                       action='store_true',
                       default=False,
                       help='Open this month\'s TODO list.')
    group.add_argument('--week',
                       action='store_true',
                       default=False,
                       help='Open this week\'s TODO list.')
    group.add_argument('--day',
                       action='store_true',
                       default=False,
                       help='Open today\'s TODO list.')
    # TODO: Add argument to sync notes with server?
    # parser.add_argument('--sync', action='store_true', help='Sync notes with master copies')

    return parser.parse_args()


def main():
    """
        Opens the note file, etc.
    """
    args = parse_args()

    # Try to use the default editor, or just insist on Vim.
    EDITOR = os.environ.get('EDITOR', 'vim')
    # Save the notes in a reasonable directory.
    NOTES_PATH = f'{Path.home()}/Documents/notes/'
    # E.g., '# Friday May 04 at 14:35:52', with an important newline.
    HEADER = f'# {datetime.now().strftime("%A %B %d at %X")}\n'

    if args.todo:
        FILENAME = 'todo.md'
    elif args.month:
        FILENAME = 'month.md'
    elif args.week:
        FILENAME = 'week.md'
    elif args.day:
        FILENAME = 'day.md'
    else:
        # E.g., '2018-05-04.md'.
        FILENAME = f'{datetime.now().strftime("%Y-%m-%d")}.md'

    # Search for the provided pattern and pass and output to stderr or stdout along.
    if args.search:
        call(['grep', '-ir', '--color=auto', args.search, NOTES_PATH])
    # Or just open the given file after appending a nice header to it.
    else:
        note = Path(NOTES_PATH + FILENAME)
        # Append the markdown header to file. Also creates the file if it doesn't exist.
        with open(note, 'a') as f:
            f.write(HEADER)

        # Ensure the file is read/writeable only by user, but only after the file is saved.
        os.chmod(note, 0o600)
        # Finally, open the file with the editor.
        call([EDITOR, note])


if __name__ == '__main__':
    main()

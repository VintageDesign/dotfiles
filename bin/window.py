#!/usr/bin/python3
import argparse
import sys


def parse_args():
    VERSION = '0.2'
    DESCRIPTION = 'window - an advanced head/tail.'
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument('-v', '--version',
                        action='version',
                        version=VERSION)
    parser.add_argument('--verbose',
                        action='store_true',
                        help='Print window dimensions.')
    parser.add_argument('from',
                        type=int,
                        nargs='?',
                        help='Beginning line number. Positive values are counted from the \
                              beginning, negative values from the end. Inclusive.',
                        default=1)
    parser.add_argument('to',
                        type=int,
                        nargs='?',
                        help='Ending line number. Positive values are counted from the    \
                              beginning, negative values from the end. Inclusive.',
                        default=-1)
    parser.add_argument('file',
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        nargs='?',
                        help='A file to use. Defaults to stdin.')

    # Turn args into a dictionary.
    args = vars(parser.parse_args())

    return args['verbose'], args['from'], args['to'], args['file']


def main():
    verbose, from_val, to_val, window_file = parse_args()
    if verbose:
        print('Taking window from line', from_val, 'to line', to_val)

    # Convert line number to index
    if from_val > 0:
        from_val -= 1

    # Negative values are one-indexed, but slicing uses exclusive endpoints.
    if to_val is -1:
        # Neat trick, list[x:None] is equivalent to list[x:]
        to_val = None
    elif to_val < 0:
        to_val += 1

    # Inefficient for extremely large amounts of data.
    for line in list(window_file)[from_val:to_val]:
        sys.stdout.write(line)


if __name__ == '__main__':
    main()

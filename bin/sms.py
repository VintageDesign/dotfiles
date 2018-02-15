#!/usr/bin/env python3
import argparse
import pathlib
import subprocess
import sys

from smslib import read_contacts, send_sms, get_ids


def parse_args():
    VERSION = '0.1'
    DESCRIPTION = 'sms.py - Send SMS message via KDE Connect'
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument('-v', '--version',
                        action='version',
                        version=VERSION)
    parser.add_argument('--verbose',
                        action='store_true',
                        help='Increase verbosity')
    parser.add_argument('-d', '--device',
                        type=str,
                        default='a9d2a0025c584e34',
                        help='The default KDE Connect device ID.')
    parser.add_argument('-r', '--recipient',
                        default='me',
                        type=str,
                        help='The phone number or contact name to send the SMS to.')
    parser.add_argument('--list',
                        action='store_true',
                        help='list device IDs known to KDE Connect.')
    parser.add_argument('--contacts',
                        type=str,
                        default=f'{str(pathlib.Path.home())}/.contacts',
                        help='The contacts file to read in.')
    parser.add_argument('--dry',
                        action='store_true',
                        default=False,
                        help='Do not send message, perform a dry run.')
    parser.add_argument('message',
                        nargs='*',
                        type=str,
                        default=sys.stdin,
                        help='The message to send.')

    return parser.parse_args()



def main():
    args = parse_args()
    contacts = read_contacts(args.contacts)

    if args.recipient.lower() in contacts:
        number = contacts[args.recipient.lower()]
    else:
        number = args.recipient.lower()
    if args.message:
        message = ' '.join(args.message)
    if args.verbose or args.dry:
        print(f'Looked up {len(contacts)} contacts from {args.contacts}')
        if args.dry:
            print('(dry run) ', end='')
        print(f'Sent "{message}" to "{number}" from device "{args.device}"')


    if args.list:
        stdout, stderr = get_ids()
        print(stdout)
    elif not args.dry:
        stdout, stderr = send_sms(message, number, args.device)
        print(stderr, file=sys.stderr)


if __name__ == '__main__':
    main()

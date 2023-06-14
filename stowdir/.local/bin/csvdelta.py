#!/usr/bin/env python3
"""Compute inter-row deltas in a CSV file.

Example CSV file:

    $ cat header.csv
    id,value,name
    0,0.1,one
    1,.75,two
    2,-3.4,three

We can calculate the inter-row deltas for the "value" column like so:

    $ csvdelta.py --input header.csv --column value
    id,value,name,value deltas
    0,0.1,one,
    1,.75,two,0.65
    2,-3.4,three,-4.15

The output will be a new CSV file with the same contents, except with a new column appended at the
end with the inter-row deltas.
"""
import argparse
import csv
import io
import logging
import sys
from typing import List, Optional, Tuple


def parse_args():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--log-level",
        "-l",
        type=str,
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Set the logging output level. Defaults to INFO.",
    )
    group = parser.add_argument_group("Input options")
    group.add_argument(
        "--input",
        "-i",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="Script input. Defaults to stdin.",
    )
    group.add_argument(
        "--output",
        "-o",
        type=argparse.FileType("w"),
        default=sys.stdout,
        help="Script output. Defaults to stdout.",
    )

    group = parser.add_argument_group("CSV options")
    group.add_argument(
        "--no-header",
        action="store_true",
        default=False,
        help="Whether the CSV file has a header",
    )
    group.add_argument(
        "--column",
        "-c",
        required=True,
        default=None,
        help="Select the specified column from the CSV file. Either column name, or index",
    )
    group.add_argument(
        "--delimiter",
        "-d",
        default=None,
        help="Specify the column delimiter.",
    )

    return parser.parse_args()


def detect_dialect(args) -> Tuple[csv.Dialect, bool]:
    """Detect the dialect of the CSV file, including whether it has a header."""
    sniffer = csv.Sniffer()
    underlying = args.input.detach()
    buffered_reader = io.BufferedReader(underlying, buffer_size=1024)
    text_reader = io.TextIOWrapper(buffered_reader)
    args.input = text_reader
    buffer = buffered_reader.peek(1024)
    buffer = buffer.decode("utf-8")
    try:
        dialect = sniffer.sniff(buffer)
    except csv.Error:
        logging.warning("Failed to sniff CSV dialect. Falling back on default")
        dialect = csv.excel
    if args.delimiter is not None and args.delimiter != dialect.delimiter:
        logging.warning(
            "Overriding detected delimiter '%s' with '%s' set from CLI --delimiter option",
            dialect.delimiter,
            args.delimiter,
        )
        dialect.delimiter = args.delimiter
    try:
        has_header = sniffer.has_header(buffer)
        logging.debug("Detected header: %s", has_header)
        if has_header and args.no_header:
            logging.warning("Detected a header, but CLI arguments specify no header")
            has_header = not args.no_header
    except csv.Error:
        logging.warning(
            "Failed to detect if CSV has a header. Falling back on CLI --no-header option"
        )
        has_header = not args.no_header

    return dialect, has_header


def column_name_to_index(column_name: str, header: Optional[List[str]]) -> int:
    """Convert the given column identifier to an index.

    Allow passing both column names and zero-based column indices.
    """
    if header is None:
        try:
            return int(column_name)
        except ValueError:
            logging.critical("Failed to find column with index '%s'", column_name)
            sys.exit(1)
    try:
        return header.index(column_name)
    # This ValueError could be nominal (user passes an index rather than a header name)
    except ValueError:
        try:
            return int(column_name)
        except ValueError:
            logging.critical("Failed to find column with name '%s'", column_name)
            sys.exit(1)


def main(args):
    dialect, has_header = detect_dialect(args)
    reader = csv.reader(args.input, dialect)

    header = None
    if has_header:
        header = next(reader)

    column_index = column_name_to_index(args.column, header)

    writer = csv.writer(args.output, dialect)
    if has_header:
        if column_index >= len(header):
            logging.critical(
                "Given column '%s' not found in header '%s'", args.column, ",".join(header)
            )
            sys.exit(1)
        old_column_name = header[column_index]
        new_column_name = old_column_name + " deltas"
        header += [new_column_name]
        writer.writerow(header)

    previous_value = None
    for row in reader:
        if column_index >= len(row):
            logging.critical("Row '%s' must be at least %d long", ", ".join(row), column_index + 1)
            sys.exit(1)
        value = row[column_index]
        try:
            value = float(value)
        except ValueError:
            logging.critical("Cannot calculate deltas of non-number '%s'", value)
            sys.exit(1)

        delta = None
        if previous_value is not None:
            delta = value - previous_value

        row += [delta]
        writer.writerow(row)

        previous_value = value


if __name__ == "__main__":
    args = parse_args()
    logging.basicConfig(
        format="%(asctime)s - %(module)s - %(levelname)s: %(message)s",
        level=args.log_level,
        stream=sys.stderr,
    )
    main(args)

#!/usr/bin/env python3
"""Calculate statistics on the given CSV file.

For example, given the following CSV file,

    $ cat example.csv
    id,value,name
    0,0.0,first
    1,0.5,second
    2,0.75,third

you can calculate summary statistics on the 'value' column like so:

    $ stats.py --column value --summary --input example.csv
    num: 3
    min: 0.0
    max: 0.75
    sum: 1.25
    mean: 0.41666666666666663
    stddev: 0.3818813079129867
"""
import argparse
import csv
import io
import logging
import math
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
    group = parser.add_argument_group("I/O options")
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
        help="Select the specified column from the CSV file",
    )
    group.add_argument(
        "--delimiter",
        "-d",
        default=",",
        help="Specify the column delimiter. Default is ','",
    )

    # # TODO:
    # # If --summary, --distribution, or --histogram are not given, these will output the centered CSV
    # # Otherwise, center the column, and then perform the given operation.
    # group = parser.add_mutually_exclusive_group()
    # group.add_argument(
    #     "--center-mean",
    #     "-m",
    #     action="store_true",
    #     default=False,
    #     help="Mean-center the given column",
    # )
    # group.add_argument(
    #     "--center-first",
    #     "-f",
    #     action="store_true",
    #     default=False,
    #     help="Center the given column around its first value",
    # )

    group = parser.add_argument_group("Statistical operations")
    group.add_argument(
        "--summary",
        "-s",
        action="store_true",
        default=False,
        help="Calculate summary statistics",
    )
    # # TODO:
    # group.add_argument(
    #     "--distribution",
    #     "-D",
    #     action="store_true",
    #     default=False,
    #     help="Estimate the distribution",
    # )
    # # TODO:
    # group.add_argument(
    #     "--histogram",
    #     "-H",
    #     metavar="BINS",
    #     type=int,
    #     default=5,
    #     nargs="?",
    #     help="Calculate the column histogram with the given number of bins. Default is 5",
    # )

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


class OnlineVariance:
    """Welford's algorithm computes the sample variance incrementally.

    Adapted from https://stackoverflow.com/a/5544108
    """

    def __init__(self, ddof=1, iterable=None):
        # delta degrees of freedom. Some stddev calculations use ddof=0 (numpy) and some use ddof=1
        # (scipy, R)
        self.ddof = ddof
        self.n = 0
        self.mean = 0
        self.M2 = 0
        self.sum = 0
        self.min = sys.float_info.max
        self.min_idx = 0
        self.max = sys.float_info.min
        self.max_idx = 0

        if iterable is not None:
            for datum in iterable:
                self.add_value(datum)

    def add_value(self, datum):
        self.sum += datum
        if datum > self.max:
            self.max = datum
            self.max_idx = self.n
        if datum < self.min:
            self.min = datum
            self.min_idx = self.n
        self.n += 1
        delta = datum - self.mean
        self.mean += delta / self.n
        self.M2 += delta * (datum - self.mean)

    @property
    def variance(self):
        return self.M2 / (self.n - self.ddof)

    @property
    def stddev(self):
        return math.sqrt(self.variance)


def main(args):
    dialect, has_header = detect_dialect(args)
    reader = csv.reader(args.input, dialect)

    header = None
    if has_header:
        header = next(reader)

    column_index = column_name_to_index(args.column, header)

    if has_header:
        if column_index >= len(header):
            logging.critical(
                "Given column '%s' not found in header '%s'", args.column, ",".join(header)
            )
            sys.exit(1)
        old_column_name = header[column_index]
        new_column_name = old_column_name + " deltas"
        header += [new_column_name]

    stats = OnlineVariance()
    for row in reader:
        if column_index >= len(row):
            logging.critical("Row '%s' must be at least %d long", ", ".join(row), column_index + 1)
            sys.exit(1)
        value = row[column_index]
        if value == "":
            continue
        try:
            value = float(value)
        except ValueError:
            logging.critical("Cannot calculate deltas of non-number '%s'", value)
            sys.exit(1)
        stats.add_value(value)

    print("num:", stats.n, file=args.output)
    print(f"min: {stats.min} index: {stats.min_idx}", file=args.output)
    print(f"max: {stats.max} index: {stats.max_idx}", file=args.output)
    print("sum:", stats.sum, file=args.output)
    print("mean:", stats.mean, file=args.output)
    print("stddev:", stats.stddev, file=args.output)


if __name__ == "__main__":
    args = parse_args()
    logging.basicConfig(
        format="%(asctime)s - %(module)s - %(levelname)s: %(message)s",
        level=args.log_level,
        stream=sys.stderr,
    )
    main(args)

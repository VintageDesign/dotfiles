import csv
import io
import logging
import sys
from typing import List, Optional, Tuple


def detect_dialect(args, input) -> Tuple[csv.Dialect, bool]:
    """Detect the dialect of the CSV file, including whether it has a header."""
    sniffer = csv.Sniffer()
    underlying = input.detach()
    buffered_reader = io.BufferedReader(underlying, buffer_size=1024)
    text_reader = io.TextIOWrapper(buffered_reader)
    input = text_reader
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

    return dialect, has_header, input


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

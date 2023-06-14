#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

SOURCE="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" >/dev/null && pwd)"

debug() {
    echo "${BLUE}DEBUG:${RESET} $*"
}

info() {
    echo "${GREEN}INFO:${RESET} $*"
}

error() {
    echo "${RED}ERROR:${RESET} $*" >&2
}

usage() {
    echo "Usage: $0 [--help] [--input INPUT] [--output-dir OUTPUT]"
    echo
    echo "Convert labeled WKT of the form"
    echo
    echo "    some-label: POLYGON((...))"
    echo "    some-label: POINT(...)"
    echo
    echo "or unlabeled WKT with one geometry per line to CSV files of the form"
    echo
    echo "    some-label.polygon.csv:"
    echo "        geometry,label"
    echo "        \"POLYGON((...))\",\"some-label\""
    echo "    some-label.point.csv:"
    echo "        geometry,label"
    echo "        \"POINT(...)\",\"some-label\""
    echo
    echo "This allows for easily generating QGIS project layers with commandline-tooling"
    echo
    echo "  --help, -h                  Show this help and exit"
    echo "  --input, -i INPUT           The input file to read the labeled WKT from. Defaults to stdin"
    echo "  --output-dir, -o OUTPUT     The directory to output the generated CSV files in. Defaults to CWD"
    echo
    echo "NOTE: This tool will happily append to any existing CSV layer files in the OUTPUT directory"
}

get_geometry_type() {
    local geometry="$1"

    echo "$geometry" | grep --only-matching --extended-regexp '^[a-zA-Z]+' | tr '[:upper:]' '[:lower:]'
}

filter_wkt() {
    local input="$1"
    echo "$input" | "$SCRIPT_DIR/filter-wkt.sh" || true
}

parse_feature_from_line() {
    local line="$1"
    # An associative array passed as a nameref. Contains the keys: "geometry", "label", and
    # "layer_type" if the given line was successfully parsed, empty otherwise.
    local -n feature="$2"

    local geometry
    local layer_type
    local label

    local -a parts
    IFS=':' read -ra parts <<<"$line"
    if [[ "${#parts[@]}" -eq 1 ]]; then
        label="unlabeled"
        geometry="${parts[0]}"
    elif [[ "${#parts[@]}" -eq 2 ]]; then
        label="${parts[0]}"
        geometry="${parts[1]}"
    else
        error "Unexpected number of :'s in '$line'"
        return
    fi
    geometry="$(filter_wkt "$geometry")"
    if [[ -z "$geometry" ]]; then
        error "Failed to extract a WKT geometry from '$line'"
        return
    fi

    set +o errexit
    layer_type="$(get_geometry_type "$geometry")"
    # shellcheck disable=SC2181
    if [[ $? -ne 0 ]]; then
        error "Failed to parse geometry type from '$geometry'"
        # Don't exit, because we want to just ignore invalid inputs
        return
    fi
    set -o errexit
    # Too verbose for nominal use
    # debug "Parsed layer type='$layer_type' from geometry='$geometry'"

    feature[geometry]="$geometry"
    feature[label]="$label"
    feature[layer_type]="$layer_type"
}

slugify() {
    local input="$1"
    echo "$input" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr '[:upper:]' '[:lower:]'
}

shellquote() {
    local input="$1"
    # using %q also escapes spaces and parentheses, but double quotes are the only thing we need to
    # escape.
    printf '%q' "$input" | sed -E 's|\\([^"])|\1|g'
    echo
}

create_layer_file_if_not_exists() {
    local layer_filename="$1"

    if [[ ! -f "$layer_filename" ]]; then
        info "Creating $layer_filename..."
        echo "geometry,label" >"$layer_filename"
    fi
}

append_feature_to_layer() {
    local layer_filename="$1"
    # shellcheck disable=SC2178
    local -n feature="$2"

    local geometry
    geometry="$(shellquote "${feature[geometry]}")"
    local label
    label="$(shellquote "${feature[label]}")"
    echo "\"$geometry\",\"$label\"" >>"$layer_filename"
}

add_line_to_layer() {
    local line="$1"
    local output_dir="$2"

    local -A parsed_feature
    parse_feature_from_line "$line" parsed_feature
    # Don't log errors here; log them at the source of the error, so that they have more contextual
    # meaning
    if [[ ! "${parsed_feature[geometry]+_}" ]]; then
        return
    elif [[ ! "${parsed_feature[label]+_}" ]]; then
        return
    elif [[ ! "${parsed_feature[layer_type]+_}" ]]; then
        return
    fi

    local layer_name="${parsed_feature[label]}"
    local layer_type="${parsed_feature[layer_type]}"

    layer_name="$(slugify "$layer_name")"
    if [[ -z "$layer_name" ]]; then
        layer_name="$layer_type"
    else
        layer_name="$layer_name.$layer_type"
    fi
    local layer_filename="$output_dir/$layer_name.csv"
    create_layer_file_if_not_exists "$layer_filename"

    append_feature_to_layer "$layer_filename" parsed_feature
}

wkt2csv() {
    local input="$1"
    local output_dir="$2"

    if [[ ! -d "$output_dir" ]]; then
        info "Creating directory '$output_dir'..."
        mkdir -p "$output_dir"
    fi

    while read -r line; do
        add_line_to_layer "$line" "$output_dir"
    done <"$input"
}

main() {
    local input="/dev/stdin"
    local output_dir="."

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --help | -h)
            usage
            exit 0
            ;;
        --input | -i)
            input="$2"
            shift
            ;;
        --output | --output-dir | -o)
            output_dir="$2"
            shift
            ;;
        *)
            error "Unexpected option: $1"
            usage >&2
            exit 1
            ;;
        esac
        shift
    done

    wkt2csv "$input" "$output_dir"
}

main "$@"

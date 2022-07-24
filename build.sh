#!/bin/sh

# Build zola site to sub-directory 'public'
#
# usage: ./build.sh [zola-dir]
#
# env vars:
#           ALPINE_VER : version of alpine (builder)
#
#           ZOLA_VER : version of zola (in alpine)
#           ZOLA_BASE_URL : base_url for zola to override default in comfig.toml
#
#           MINIFY_VER : version of minify (in alpine)
#           MINIFY_ARGS : additional arguments of minify
#           NO_MINIFY : do not perform any minify if env is set
#
#           GZIP_TARGET_EXTENSIONS : file extensions list to compress with gzip,
#                                    separated with space.
#                                    set to a single space (' ') to disable gzip compression
#           GZIP_COMPRESSION_LEVEL : compression level of gzip
#
# example: $ ./build.sh
#          $ ./build.sh root-zola-dir
#          $ ZOLA_VER=0.15.3 NO_MINIFY=true ./build.sh



# determine container command to run
if podman --version > /dev/null 2>&1
then
  CONTAINER_BINNAME=podman
elif docker --version > /dev/null 2>&1
then
  CONTAINER_BINNAME=docker
else
  printf "No podman or docker binary found!\n" >&2
  exit 1
fi



# export all env vars
ZOLA_DIR="${1:-$(dirname ./*/config.toml | head -n1 2> /dev/null)}"
[ -n "$1" ] && shift
[ -n "$ZOLA_DIR" ] && \
  printf "Building a Zola directory: '%s'\n" "$ZOLA_DIR" >&2 \
  || \
  printf "%s\n" \
         "Zola root sub-directory is not given, and no Zola candidate directory found!" \
         >&2



IMG_NAME=zola-pages-builder
IMG_TAG="$(tr -dc '[:alpha:]' < /dev/urandom | head -c30)"
OUTPUT_DIR="${OUTPUT_DIR:-public}"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

if iid=$("$CONTAINER_BINNAME" \
           build . \
           -f Containerfile \
           --rm -q -t "$IMG_NAME":"$IMG_TAG" \
           \
           ${ALPINE_VER:+--build-arg=alpine_ver="$ALPINE_VER"} \
           \
           ${ZOLA_VER:+--build-arg=zola_ver="$ZOLA_VER"} \
           --build-arg=zola_dir="$ZOLA_DIR" \
           ${ZOLA_BASE_URL:+--build-arg=zola_base_url="$ZOLA_BASE_URL"} \
           \
           --build-arg=minify_ver="$MINIFY_VER" \
           ${MINIFY_ARGS:+--build-arg=minify_args="$MINIFY_ARGS"} \
           ${NO_MINIFY:+--build-arg=no_minify="$NO_MINIFY"} \
           \
           ${GZIP_TARGET_EXTENSIONS:+--build-arg=gzip_target_extensions="$GZIP_TARGET_EXTENSIONS"} \
           ${GZIP_COMPRESSION_LEVEL:+--build-arg=gzip_compression_level="$GZIP_COMPRESSION_LEVEL"} \
      ) \
    && cid=$("$CONTAINER_BINNAME" create "$IMG_NAME":"$IMG_TAG") \
    && "$CONTAINER_BINNAME" cp "$cid":/public/. "$OUTPUT_DIR"
then success=true; else success=false; fi



if [ -n "$iid" ]; then "$CONTAINER_BINNAME" rmi -f "$iid" > /dev/null; fi

if $success
then
  printf "Zola build success: Outputs are stored at path: '%s'\n" "$OUTPUT_DIR" >&2
  exit 0
else
  printf "Zola build FAILED!\n" >&2
  exit 1
fi

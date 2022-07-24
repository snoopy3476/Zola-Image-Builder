#!/bin/sh

# Build zola site, build a web server container image of it, then run the image for test
#
# usage: ./test-img.sh [zola-dir]
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
#           THTTPD_VER : thttpd (webserver) version
#           CACHE_MAX_AGE : http cache-control max-age value in seconds (for thttpd)
#
#           EXTERNAL_PORT : external port to get http request on test run
#
# example: $ ./test-img.sh
#          $ ./test-img.sh root-zola-dir
#          $ ZOLA_VER=0.15.3 CACHE_MAX_AGE=3600 EXTERNAL_PORT=9000 ./test-img.sh



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



IMG_NAME=zola-pages-builder-imgtest
IMG_TAG="$(tr -dc '[:alpha:]' < /dev/urandom | head -c30)"

SIG_LIST="INT HUP QUIT ABRT TERM"
trap "" $SIG_LIST
iid=$(./img-build.sh "$IMG_NAME":"$IMG_TAG" "$1") \
  && printf "\n\n * Running built image... (http://localhost:%s)\n   Press Ctrl+C to stop.\n" \
            "${EXTERNAL_PORT:-8000}" \
  && "$CONTAINER_BINNAME" run --rm -p "${EXTERNAL_PORT:-8000}":80 "$iid"
trap - $SIG_LIST



if [ -n "$iid" ]
then
  "$CONTAINER_BINNAME" rmi -f "$IMG_NAME":"$IMG_TAG" > /dev/null \
    && printf "\n\n * Test image removed.\n";
fi

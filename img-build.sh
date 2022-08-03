#!/bin/sh

# Build zola site, then build a web server container image that serves the zola site
#
# usage: ./img-build.sh img-name-and-tag [zola-dir]
#
# env vars:
#           ALPINE_VER : version of alpine (builder)
#
#           ZOLA_VER : version of zola (in alpine)
#           ZOLA_BASE_URL : base_url for zola to override default in comfig.toml
#
#           THTTPD_VER : thttpd (webserver) version
#           CACHE_MAX_AGE : http cache-control max-age value in seconds (for thttpd)
#
# example: $ ./img-build.sh my-container-img-name
#          $ ./img-build.sh my-container-img-name root-zola-dir
#          $ ZOLA_VER=0.16.0 CACHE_MAX_AGE=3600 ./img-build.sh my-container-img-name



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



IMG_NAME="${1?Image name to build not given!
usage: ${0} <img-name> [zola-dir]}"
shift
OUTPUT_DIR="public"



if OUTPUT_DIR="$OUTPUT_DIR" ./build.sh "$1" \
    && printf "\n * Building Webserver Image (THTTPD)...\n" >&2 \
     && iid=$("$CONTAINER_BINNAME" \
                build . \
                -f Containerfile \
                -t "$IMG_NAME" \
                --rm -q \
                --build-arg=input_dir="$OUTPUT_DIR" \
                ${ALPINE_VER:+--build-arg=alpine_ver="$ALPINE_VER"} \
                ${THTTPD_VER:+--build-arg=thttpd_ver="$THTTPD_VER"} \
                ${CACHE_MAX_AGE:+--build-arg=cache_max_age="$CACHE_MAX_AGE"})
then success=true; else success=false; fi

printf "%s\n" "$iid"



if $success
then
  printf "Zola thttpd build success: Output container image is built as: '%s'\n" "$IMG_NAME" >&2
  exit 0
else
  printf "Zola thttpd build FAILED!\n" >&2
  exit 1
fi


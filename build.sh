#!/bin/sh

# Build zola site to sub-directory 'public'
#
# usage: ./build.sh [zola-dir]
#
# env vars:
#           ZOLA_VER : version of zola (in alpine)
#           ZOLA_BASE_URL : base_url for zola to override default in comfig.toml
#
# example: $ ./build.sh
#          $ ./build.sh root-zola-dir
#          $ ZOLA_VER=0.15.3 ./build.sh





##### ENVS #####


# general envs
OUTPUT_DIR="${OUTPUT_DIR:-public}"


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


# find zola latest if ZOLA_VER is not defined
if [ -z "$ZOLA_VER" ]
then
  printf "ZOLA_VER is not defined! Checking the latest version...\n" >&2
  ZOLA_VER_LIST="$(\
                  git ls-remote -t https://github.com/getzola/zola.git v[0-9]*.[0-9]*.[0-9]* \
                    | grep -v ".*^{}$" \
                    | cut -f2 \
                    | rev | cut -dv -f1 | rev \
                    | sort --version-sort --reverse \
               )" >&2
  for v in $ZOLA_VER_LIST
  do
    printf "Checking version 'v%s'...\n" "${v}" >&2
    "$CONTAINER_BINNAME" manifest inspect ghcr.io/getzola/zola:v"${v}" 2> /dev/null >&2 && ZOLA_VER="${v}" && break
  done
fi





##### BUILD & OPTIMIZE #####


# zola build

printf "\n * Building Zola...\n" >&2
rm -rf "$OUTPUT_DIR"
TMP_BUILD_DIR="$(mktemp -d)"
if "$CONTAINER_BINNAME" run --rm -i \
                        -v "${TMP_BUILD_DIR}":/build -v "$ZOLA_DIR":/src \
                        --workdir /src \
                        \
                        ghcr.io/getzola/zola:v"${ZOLA_VER}" build -o /build/output \
                        ${ZOLA_BASE_URL:+-u} ${ZOLA_BASE_URL:+"${ZOLA_BASE_URL}"} >&2 \
     && { mv -f "${TMP_BUILD_DIR}"/output "$OUTPUT_DIR" 2> /dev/null || true ; } ; \
then success=true; else success=false; fi
rm -rf "${TMP_BUILD_DIR}"


# optimizer pass: optimize for each optimizer script

TMP_PROC_DIR="$(mktemp -d)"
OPTIMIZER_LIST="$(find "${PWD}/optimizer" -type f -executable | sort)"
ln -snf "${PWD}/${OUTPUT_DIR}" "${TMP_PROC_DIR}"/input
mkdir -p "${TMP_PROC_DIR}"/output

if [ "$success" = "true" ] && (
     cd "$TMP_PROC_DIR" || exit 1
     printf "%s\n" "$OPTIMIZER_LIST" | while read -r opt_script
     do
       printf "\n * Running optimizer pass '%s'...\n" "$(basename "$opt_script")" >&2

       if ! "$opt_script" >&2
       then
         printf " *** Optimizer failed: '%s'" "$opt_script"
         exit 1
       fi

       rm -rf ./input/* ./input/.[!.]* ./input/..?*
       mv ./output/* ./output/.[!.]* ./output/..?* input/ 2> /dev/null
     done
     true
   )
then success=true; else success=false; fi

rm "${TMP_PROC_DIR}"/input
rm -rf "${TMP_PROC_DIR}"





##### PRINT RESULT #####


if $success
then
  printf "\n\n * Zola build success: Outputs are stored at path: '%s'\n" "$OUTPUT_DIR" >&2
  exit 0
else
  printf "\n\n * Zola build FAILED!\n" >&2
  exit 1
fi

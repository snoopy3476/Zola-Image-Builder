### ARGS LIST ###
# alpine_ver : version of alpine (builder)
#
# zola_ver : version of zola (in alpine)
# zola_dir : zola source root directory
# zola_base_url : base_url for zola to override default in comfig.toml
#
# minify_ver : version of minify (in alpine)
# minify_args : additional arguments of minify
# no_minify : do not perform any minify
#
# gzip_target_extensions : file extensions list to compress with gzip, separated with space
# gzip_compression_level : compression level of gzip
#

# Author: Kim Hwiwon <kim.hwiwon@outlook.com>
# License: The MIT License (MIT)



# init builder image
ARG alpine_ver="latest"
FROM alpine:${alpine_ver} AS builder



# build zola
ARG zola_ver=""
ARG zola_dir
ARG zola_base_url=""
COPY "${zola_dir}" /zola
WORKDIR /zola

RUN apk add zola"${zola_ver:+~$zola_ver}" >&2
RUN printf "\n\n * Building Zola...\n" >&2 ; \
    zola build -o /public ${zola_base_url:+-u} ${zola_base_url:+"$zola_base_url"} >&2



# minify
ARG minify_ver=""
ARG minify_args=""
ARG no_minify=""

RUN if [ -z "$no_minify" ]; \
    then \
        printf "\n\n * Minifying outputs...\n" >&2 ; \
        apk add minify"${minify_ver:+~$minify_ver}" >&2 \
          && minify -r /public -o / $minify_args >&2 \
        || exit 1; \
    fi
RUN [ -z "$no_minify" ] || printf "\n\n * Minification is disabled by user!\n" >&2



# compress text (gzip)
ARG gzip_target_extensions="html css js xml txt"
ARG gzip_compression_level="9"

RUN find_pattern_str=""; \
    for ext in $gzip_target_extensions; \
    do \
        if [ -n "$find_pattern_str" ]; \
        then \
            find_pattern_str="$find_pattern_str -o "; \
        fi; \
        find_pattern_str="$find_pattern_str""-name *.""$ext"; \
    done; \
    \
    if [ -n "$find_pattern_str" ]; \
    then \
        printf "\n\n * Gzip compressing outputs: %s\n" "$gzip_target_extensions" >&2 ; \
        find /public \( $find_pattern_str \) \
          -exec gzip -kf "-${gzip_compression_level}" {} + >&2 || exit 1 ; \
    else \
        printf "\n\n * Gzip compression is disabled by user!\n" >&2 ; \
    fi

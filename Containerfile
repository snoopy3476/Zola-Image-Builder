# Build a static webserver image with 'public' directory.
#
# This Containerfile is not building static site files automatically:
#   place site files for static webserver inside 'public' directory before build!

### ARGS LIST ###
# input_dir : directory of static site files to serve
#
# alpine_ver : version of alpine (builder)
#
# thttpd_ver : version of thttpd (in alpine)
# cache_max_age : http cache-control max-age value in seconds (for thttpd)
#

# Author: Kim Hwiwon <kim.hwiwon@outlook.com>
# License: The MIT License (MIT)

ARG alpine_ver="latest"
FROM alpine:${alpine_ver}
ARG thttpd_ver=""
RUN apk add --no-cache thttpd"${thttpd_ver:+~$thttpd_ver}" >&2

RUN adduser --disabled-password --home /public thttpd-runner
ARG input_dir="public"
COPY "${input_dir}" /public
RUN chown -R thttpd-runner /public >&2

EXPOSE 80

ARG cache_max_age=600
ENV CACHE_MAX_AGE=${cache_max_age}
CMD [ "sh", "-c", "thttpd -D -d /public -u thttpd-runner -l - -M ${CACHE_MAX_AGE}" ]

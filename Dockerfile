FROM alpine:3.21.2

ARG LIGHTTPD_VERSION=1.4.77-r0

# Install lighttpd from binary package and remove default conf
RUN set -x \
    && apk add --no-cache \
    lighttpd${LIGHTTPD_VERSION:+=}${LIGHTTPD_VERSION} \
    curl \
    && rm -rvf /var/cache/apk/* \
    && rm -rvf /etc/lighttpd/* /var/www/localhost \
    && mkdir -vp /var/www/html

# Copy configuration
COPY etc/ /etc/lighttpd/

# Check configuration is ok
RUN lighttpd -tt -f /etc/lighttpd/lighttpd.conf

# Expose port and entrypoint
EXPOSE 80/tcp
ENTRYPOINT ["/usr/sbin/lighttpd"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "-s", "--fail", "http://127.0.0.1/server-status?auto" ]
CMD ["-D", "-f", "/etc/lighttpd/lighttpd.conf"]
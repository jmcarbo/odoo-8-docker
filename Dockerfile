#FROM debian:jessie
FROM ubuntu:16.04
MAINTAINER Odoo S.A. <info@odoo.com>
LABEL org.opencontainers.image.source https://github.com/jmcarbo/odoo-8-docker
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH
# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            wget \
            node-less \
            node-clean-css \
            python-pyinotify 
            #python-renderpm 
RUN wget -O wkhtmltox.deb  "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_$TARGETARCH.deb" \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends 
#            python-support \
#      && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
#        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
#        && dpkg --force-depends -i wkhtmltox.deb \
#        && apt-get -y install -f --no-install-recommends \
#        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
#        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install Odoo
ENV ODOO_VERSION 8.0
ENV ODOO_RELEASE 20171001
#http://nightly.odoo.com/8.0/nightly/deb/odoo_8.0.20171001_all.deb
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && dpkg --force-depends -i odoo.deb \
        #&& dpkg -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f  
        #&& apt-get install -y --fix-broken 
        #&& rm -rf /var/lib/apt/lists/* odoo.deb
#        && echo '8d3454047891074cc0805d30f11dd393831d69d8 odoo.deb' | sha1sum -c - \


# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf && chmod +x /entrypoint.sh

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]

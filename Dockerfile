FROM collabora/code:25.04.8.1.1

COPY coolwsd.xml /etc/coolwsd/coolwsd.xml
COPY start.sh /start.sh

# Image content modification steps
USER root

# Install locales so that the lang URL parameter correctly controls
# date/number formatting in LibreOffice (fi, sv, en).
# The base image lacks debconf, so we unpack the locales package manually
# and generate only the locales we need with localedef.
RUN apt-get update -qq \
    && apt-get download locales libc-l10n \
    && dpkg-deb -x locales_*.deb / \
    && dpkg-deb -x libc-l10n_*.deb / \
    && rm -f *.deb \
    && localedef -i fi_FI -f UTF-8 fi_FI.UTF-8 \
    && localedef -i sv_SE -f UTF-8 sv_SE.UTF-8 \
    && localedef -i en_GB -f UTF-8 en_GB.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && coolwsd-systemplate-setup /opt/cool/systemplate /opt/collaboraoffice

# Create WOPI proof mount volume so cool user can write to it
RUN mkdir -p /mnt/wopi-proof
RUN chown cool:cool /mnt/wopi-proof

# Disable welcome message
RUN sed -i "s|%ENABLE_WELCOME_MSG%|false|g" /usr/share/coolwsd/browser/dist/cool.html

# Disable feedback popup
RUN sed -i "s|%AUTO_SHOW_FEEDBACK%|false|g" /usr/share/coolwsd/browser/dist/cool.html

# Remove autocorrect, autotext etc. features
RUN rm -rf /opt/collaboraoffice/share/autocorr/*
RUN rm -rf /opt/collaboraoffice/share/autotext/*
RUN rm -rf /opt/collaboraoffice/share/extensions/*
RUN rm -rf /opt/collaboraoffice/share/wordbook/*
RUN rm -rf /opt/collaboraoffice/share/fingerprint/*
RUN rm -rf /opt/collaboraoffice/share/numbertext/*

USER cool

ENTRYPOINT [ "/start.sh" ]

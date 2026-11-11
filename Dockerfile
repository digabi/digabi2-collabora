FROM collabora/code:26.04.6.1.1

COPY coolwsd.xml /etc/coolwsd/coolwsd.xml
COPY start.sh /start.sh

# CODE 26.04 is distroless and ships no shell. Busybox provides only the
# commands used below and by start.sh, including wget.
USER root
COPY --from=busybox:1.37.0-musl /bin/busybox /bin/busybox
RUN ["/bin/busybox", "sh", "-c", "cd /bin && for cmd in sh sed cp chmod sleep mkdir chown rm wget; do /bin/busybox ln -s busybox \"$cmd\"; done"]

# start.sh runs as the cool user. It writes proof keys and sed -i temp files
# into root-owned /etc/coolwsd, and the public key into /mnt/wopi-proof.
RUN mkdir -p /mnt/wopi-proof
RUN chown cool:cool /mnt/wopi-proof
RUN chown -R cool:cool /etc/coolwsd

# Disable welcome message
RUN sed -i "s|%ENABLE_WELCOME_MSG%|false|g" /usr/share/coolwsd/browser/dist/cool.html

# Disable feedback popup
RUN sed -i "s|%AUTO_SHOW_FEEDBACK%|false|g" /usr/share/coolwsd/browser/dist/cool.html

# The first-visit tour has no config switch. Treat it as already seen so it does not open on its own
RUN sed -i 's|getBooleanDocTypePref("onboardingTourSeen",!1)|getBooleanDocTypePref("onboardingTourSeen",!0)|' /usr/share/coolwsd/browser/dist/bundle.js \
 && /bin/busybox grep -q 'getBooleanDocTypePref("onboardingTourSeen",!0)' /usr/share/coolwsd/browser/dist/bundle.js

# Remove autocorrect, autotext etc. features
RUN rm -rf /opt/collaboraoffice/share/autocorr/*
RUN rm -rf /opt/collaboraoffice/share/autotext/*
RUN rm -rf /opt/collaboraoffice/share/extensions/*
RUN rm -rf /opt/collaboraoffice/share/wordbook/*
RUN rm -rf /opt/collaboraoffice/share/fingerprint/*
RUN rm -rf /opt/collaboraoffice/share/numbertext/*

USER cool

ENTRYPOINT [ "/start.sh" ]

FROM collabora/code:24.04.13.3.1

COPY coolwsd.xml /etc/coolwsd/coolwsd.xml
COPY start.sh /start.sh

# Image content modification steps
USER root

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

CMD [ "/start.sh" ]

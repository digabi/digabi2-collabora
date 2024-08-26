FROM collabora/code:24.04.2.1.1

COPY coolwsd.xml /etc/coolwsd/coolwsd.xml

# Disable welcome message
USER root
RUN sed -i "s|%ENABLE_WELCOME_MSG%|false|g" /usr/share/coolwsd/browser/dist/cool.html
USER cool
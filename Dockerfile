FROM debian:13

LABEL maintainer="Chiwan Park <chiwanpark@hotmail.com>"

USER root

# global configuration
COPY ./config-global/ /tmp/workbench/
RUN cd /tmp/workbench/ \
 && for script in 00_*.sh 10_*.sh; do \
      if [ -f "${script}" ]; then \
        echo "Running ${script}"; \
        /bin/bash "${script}"; \
      fi; \
    done \
 && rm -rf /tmp/workbench/

# user configuration
COPY ./config-local/ /etc/config-local/

# entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/zsh", "--login"]

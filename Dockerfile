FROM 1password/connect-api:1.8.2 AS api
FROM 1password/connect-sync:1.8.2 AS sync

FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tini \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home opuser \
 && mkdir -p /home/opuser/.op/data \
 && chown -R opuser:opuser /home/opuser/.op \
 && chmod 700 /home/opuser/.op /home/opuser/.op/data
COPY --from=api  /bin/connect-api  /usr/local/bin/connect-api
COPY --from=sync /bin/connect-sync /usr/local/bin/connect-sync
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
USER opuser
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/start.sh"]

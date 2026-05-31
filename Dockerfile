FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server
COPY garmin_mcp_server.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Garth tokens persisted here (mount as volume)
RUN mkdir -p /data/garth
ENV GARTH_TOKEN_DIR=/data/garth

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD python -c "import urllib.request; r=urllib.request.Request('http://localhost:8000/mcp',method='POST',headers={'Content-Type':'application/json','Accept':'application/json, text/event-stream'},data=b'{\"jsonrpc\":\"2.0\",\"method\":\"ping\",\"id\":1}'); urllib.request.urlopen(r)" || exit 1

ENTRYPOINT ["./entrypoint.sh"]

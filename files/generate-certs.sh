#!/usr/bin/env bash
# generate-certs.sh
# Generates a CA and TLS certificates for OpenSearch, OpenSearch Dashboards,
# and the OpenTelemetry Collector, then emits a Kubernetes Secret manifest
# (stringData format) suitable for kubectl apply.
#
# Usage:
#   bash files/generate-certs.sh | kubectl apply -f -
#
# Requirements: openssl

set -euo pipefail

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

OU="opensearch-otel"
DAYS=3650

# ---------- CA ----------
openssl genrsa -out "$TMPDIR/ca.key" 4096 2>/dev/null
openssl req -new -x509 -days "$DAYS" -key "$TMPDIR/ca.key" \
  -subj "/CN=opensearch-otel-ca/OU=$OU" \
  -out "$TMPDIR/ca.crt" 2>/dev/null

sign_cert() {
  local name="$1"
  local cn="$2"

  openssl genrsa -out "$TMPDIR/$name.key" 2048 2>/dev/null

  openssl req -new -key "$TMPDIR/$name.key" \
    -subj "/CN=$cn/OU=$OU" \
    -out "$TMPDIR/$name.csr" 2>/dev/null

  openssl x509 -req -days "$DAYS" \
    -in "$TMPDIR/$name.csr" \
    -CA "$TMPDIR/ca.crt" \
    -CAkey "$TMPDIR/ca.key" \
    -CAcreateserial \
    -out "$TMPDIR/$name.crt" 2>/dev/null
}

# ---------- Component certificates ----------
sign_cert "opensearch"      "opensearch"
sign_cert "dashboards"      "dashboards"
sign_cert "otel-collector"  "otel-collector"

# ---------- Emit Kubernetes Secret manifest ----------
indent() {
  sed 's/^/    /'
}

cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: opensearch-tls
type: Opaque
stringData:
  ca.crt: |
$(indent < "$TMPDIR/ca.crt")
  ca.key: |
$(indent < "$TMPDIR/ca.key")
  opensearch.crt: |
$(indent < "$TMPDIR/opensearch.crt")
  opensearch.key: |
$(indent < "$TMPDIR/opensearch.key")
  dashboards.crt: |
$(indent < "$TMPDIR/dashboards.crt")
  dashboards.key: |
$(indent < "$TMPDIR/dashboards.key")
  otel-collector.crt: |
$(indent < "$TMPDIR/otel-collector.crt")
  otel-collector.key: |
$(indent < "$TMPDIR/otel-collector.key")
EOF

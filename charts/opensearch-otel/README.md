# opensearch-otel

A Helm chart that deploys **OpenSearch**, **OpenSearch Dashboards**, and an **OpenTelemetry Collector** (contrib) wired together with mutual TLS.

## Prerequisites

- Helm v3
- A Kubernetes Secret containing TLS assets (see [Generating Certificates](#generating-certificates))

## Generating Certificates

Use the helper script in the repository root to generate a CA, node certificates for OpenSearch, Dashboards, and the OTel Collector, and produce a ready-to-apply Kubernetes Secret manifest:

```bash
bash files/generate-certs.sh | kubectl apply -f -
```

The script outputs a Secret named `opensearch-tls` (matching the `tls.secretName` default) in `stringData` format.

## Installing the Chart

```bash
helm install opensearch-otel ./charts/opensearch-otel
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opensearch.image` | OpenSearch container image | `opensearchproject/opensearch:2.13.0` |
| `opensearch.username` | OpenSearch admin username | `admin` |
| `opensearch.password` | OpenSearch admin password | `admin` |
| `opensearch.port` | OpenSearch HTTP port | `9200` |
| `opensearch.transportPort` | OpenSearch transport port | `9300` |
| `dashboards.image` | OpenSearch Dashboards image | `opensearchproject/opensearch-dashboards:2.13.0` |
| `dashboards.port` | Dashboards HTTP port | `5601` |
| `collector.image` | OTel Collector (contrib) image | `otel/opentelemetry-collector-contrib:0.97.0` |
| `collector.grpcPort` | OTel OTLP gRPC port | `4317` |
| `collector.httpPort` | OTel OTLP HTTP port | `4318` |
| `tls.secretName` | Name of the Kubernetes Secret holding TLS assets | `opensearch-tls` |

## Architecture

```
OTLP data → OTel Collector → OpenSearch (HTTPS + mTLS)
                                      ↑
                          OpenSearch Dashboards
```

All three components share the TLS Secret mounted as a volume.

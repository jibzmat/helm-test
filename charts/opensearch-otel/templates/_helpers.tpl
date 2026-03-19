{{/*
Expand the name of the chart.
*/}}
{{- define "opensearch-otel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "opensearch-otel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opensearch-otel.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "opensearch-otel.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opensearch-otel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opensearch-otel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

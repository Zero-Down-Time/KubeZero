{{- /*
Common naming functions
*/ -}}
{{- define "kubezero-lib.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kubezero-lib.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if .subchart }}
{{- $name = default .subchart .Values.nameOverride -}}
{{- end -}}
{{- if or (contains $name .Release.Name) (contains $name (printf "%s-%s" "kubezero" .Release.Name)) -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "kubezero-lib.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- /*
Selector labels
*/ -}}
{{- define "kubezero-lib.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubezero-lib.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- /*
Common set of labels
*/ -}}
{{- define "kubezero-lib.labels" -}}
helm.sh/chart: {{ include "kubezero-lib.chart" . }}
{{ include "kubezero-lib.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: kubezero
{{- end -}}

{{- /*
kubezero-lib.util.merge will merge two YAML templates and output the result.
This takes an array of three values:
- the top context
- the template name of the overrides (destination)
- the template name of the base (source)
*/ -}}
{{- define "kubezero-lib.util.merge" -}}
{{- $top := first . -}}
{{- $overrides := fromYaml (include (index . 1) $top) | default (dict ) -}}
{{- $tpl := fromYaml (include (index . 2) $top) | default (dict ) -}}
{{- toYaml (merge $overrides $tpl) -}}
{{- end -}}

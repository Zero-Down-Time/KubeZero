{{- define "gatewayServers" }}

{{- range $port := .ports }}
{{- if not $port.noGateway }}

{{- $eachCert := false }}
{{- if $port.tls }}
{{- if not $port.tls.httpsRedirect }}
{{- $eachCert = true }}
{{- end }}
{{- end }}

{{- if $eachCert }}
{{- range $cert := $.certificates }}
- port:
    number: {{ $port.port }}
    name: {{ $port.name }}-{{ $cert.name }}
    protocol: {{ default "TCP" $port.gatewayProtocol }}
  tls:
    credentialName: {{ $cert.name }}
    {{- toYaml $port.tls | nindent 4 }}
  hosts:
  {{- toYaml $cert.dnsNames | nindent 2 }}
{{- end }}
{{- else }}
- port:
    number: {{ $port.port }}
    name: {{ $port.name }}
    protocol: {{ default "TCP" $port.gatewayProtocol }}
  {{- with $port.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  hosts:
  {{- if $port.hosts }}
    {{- toYaml $port.hosts | nindent 4 }}
  {{- else }}
  {{- range $cert := $.certificates }}
  {{- toYaml $cert.dnsNames | nindent 2 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- end }}
{{- end }}


{{- define "gatewayName" -}}
{{ .Values.gateway.name | default .Release.Name | default "istio-ingressgateway" }}
{{- end }}


{{- define "gatewaySelectorLabels" -}}
app: {{ include "gatewayName" . }}
istio: {{ include "gatewayName" . | trimPrefix "istio-" }}
{{- end }}

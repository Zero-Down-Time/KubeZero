#!/usr/bin/env bash

set -euo pipefail

{{- if .Values.initPreScript }}
# BEGIN: initPreScript
{{- with .Values.initPreScript -}}
{{ . | nindent 4}}
{{- end -}}
# END: initPreScript
{{- end }}

set -x

{{- if not .Values.image.rootless }}
chown 1000:1000 /data
{{- end }}
mkdir -p /data/git/.ssh
chmod -R 700 /data/git/.ssh
[ ! -d /data/gitea/conf ] && mkdir -p /data/gitea/conf

# prepare temp directory structure
mkdir -p "${GITEA_TEMP}"
{{- if not .Values.image.rootless }}
chown 1000:1000 "${GITEA_TEMP}"
{{- end }}
chmod ug+rwx "${GITEA_TEMP}"

{{ if .Values.signing.enabled -}}
if [ ! -d "${GNUPGHOME}" ]; then
  mkdir -p "${GNUPGHOME}"
  chmod 700 "${GNUPGHOME}"
  chown 1000:1000 "${GNUPGHOME}"
fi
{{- end }}

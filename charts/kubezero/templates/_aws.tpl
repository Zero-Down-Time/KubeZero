{{- define "aws-iam-env" -}}
- name: AWS_ROLE_ARN
  value: "arn:aws:iam::{{ $.Values.global.aws.accountId }}:role/{{ $.Values.global.aws.region }}.{{ $.Values.global.clusterName }}.{{ .roleName }}"
- name: AWS_WEB_IDENTITY_TOKEN_FILE
  value: "/var/run/secrets/sts.amazonaws.com/serviceaccount/token"
- name: AWS_STS_REGIONAL_ENDPOINTS
  value: "regional"
- name: METADATA_TRIES
  value: "0"
- name: AWS_REGION
  value: {{ $.Values.global.aws.region }}
{{- end }}


{{- define "aws-iam-volumes" -}}
- name: aws-token
  projected:
    sources:
    - serviceAccountToken:
        path: token
        expirationSeconds: 86400
        audience: "sts.amazonaws.com"
{{- end }}


{{- define "aws-iam-volumemounts" -}}
- name: aws-token
  mountPath: "/var/run/secrets/sts.amazonaws.com/serviceaccount/"
  readOnly: true
{{- end }}

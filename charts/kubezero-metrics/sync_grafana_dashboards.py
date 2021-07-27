#!/usr/bin/env python3

import sys
import json
import yaml
import requests
import textwrap
import io
import gzip
import base64

config_file = sys.argv[1]
configmap_file = sys.argv[2]


def traverse_json(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            # CloudBender::StackRef
            if k == "datasource" and v:
                obj[k] = "Prometheus"

            if isinstance(v, dict) or isinstance(v, list):
                traverse_json(v)

    elif isinstance(obj, list):
        for k in obj:
            if isinstance(k, dict) or isinstance(k, list):
                traverse_json(k)


# read config file
with open(config_file, 'r') as yaml_contents:
    config = yaml.safe_load(yaml_contents.read())


configmap = ''
if 'condition' in config:
    # use index function to make go template happy if '-' in names
    if '-' in config['condition'] and "index" not in config['condition']:
        tokens = config['condition'].split('.')
        configmap = '''{{- if index .Values %(condition)s }}
''' % {'condition': ' '.join(f'"{w}"' for w in tokens[2:])}

    else:
        configmap = '''{{- if %(condition)s }}
''' % config

# Base configmap for KubeZero
configmap += '''apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ printf "%%s-%%s" (include "kubezero-lib.fullname" $) "%(configmap)s" | trunc 63 | trimSuffix "-" }}
  namespace: {{ .Release.Namespace }}
  labels:
    grafana_dashboard: "1"
{{ include "kubezero-lib.labels" . | indent 4 }}
''' % config

# Put all dashboards into a folder ?
if 'folder' in config:
    configmap += '''  annotations:
    k8s-sidecar-target-directory: %(folder)s
''' % config

# compress ?
if 'gzip' in config and config['gzip']:
    configmap += '''binaryData:
'''
else:
    configmap += '''data:
'''

for b in config['dashboards']:
    if not b['url'].startswith('file://'):
        response = requests.get(b['url'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text
    else:
        with open(b['url'].replace('file://', ''), 'r') as file_contents:
            raw_text = file_contents.read()

    obj = json.loads(raw_text)

    # replace datasources
    traverse_json(obj)
   
    # Set default tim in all charts to 1h
    obj['time'] = { "from": "now-1h", "to": "now" }
    obj['refresh'] = "30s"

    # set tags
    if 'tags' in b:
      obj['tags'] = b['tags']

    text = json.dumps(obj, indent=2)

    if 'gzip' in config and config['gzip']:
        # compress and base64 encode
        buf = io.BytesIO()
        f = gzip.GzipFile(mode='w', fileobj=buf, mtime=0)
        f.write(text.encode())
        f.close()

        textb64 = base64.b64encode(buf.getvalue()).decode('utf-8')
        textb64 = textwrap.indent(textb64, ' '*4)
        configmap += '''  %(name)s.json.gz:
''' % b
        configmap += textb64+'\n'
    else:
        # encode otherwise helm will mess with raw json
        text = text.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")
        text = textwrap.indent(text, ' '*4)
        configmap += '''  %(name)s.json:
''' % b
        configmap += text+'\n'


if 'condition' in config:
    configmap += '{{- end }}'+'\n'

# Write Configmap
with open(configmap_file, 'w') as f:
    f.write(configmap)

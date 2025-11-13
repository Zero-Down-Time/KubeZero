#!/usr/bin/env python3

import sys
import os
import json
import yaml
import requests
import textwrap

config_file = sys.argv[1]
configmap_folder = sys.argv[2]

# basepath of config_file for file:// URLs later one
config_file_path = os.path.dirname(config_file)

# read config file
with open(config_file, "r") as yaml_contents:
    config = yaml.safe_load(yaml_contents.read())


def base_rule(config):
    rule = ""
    if "condition" in config:
        # use index function to make go template happy if '-' in names
        if "-" in config["condition"] and "index" not in config["condition"]:
            tokens = config["condition"].split(".")
            rule = """{{- if index .Values %(condition)s }}
    """ % {
                "condition": " ".join(f'"{w}"' for w in tokens[2:])
            }

        else:
            rule = (
                """{{- if %(condition)s }}
"""
                % config
            )

    # Base rule for KubeZero
    rule += (
        """apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ printf "%%s-%%s" (include "kubezero-lib.fullname" $) "%(name)s" | trunc 63 | trimSuffix "-" }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "kubezero-lib.labels" . | nindent 4 }}
"""
        % config
    )

    return rule


for r in config["rules"]:
    if not r["url"].startswith("file://"):
        response = requests.get(r["url"])
        if response.status_code != 200:
            print(
                "Skipping the file, response code %s not equals 200"
                % response.status_code
            )
            continue
        raw_text = response.text
    else:
        with open(os.path.join(config_file_path, r["url"].replace("file://", "")), "r") as file_contents:
            raw_text = file_contents.read()

    obj = json.loads(raw_text)

    rule = base_rule(r)

    text = yaml.dump(obj["spec"], default_flow_style=False, width=1000, indent=2)

    # Encode {{ }} for helm
    text = (
        text.replace("{{", "{{`{{")
        .replace("}}", "}}`}}")
        .replace("{{`{{", "{{`{{`}}")
        .replace("}}`}}", "{{`}}`}}")
    )

    rule += """spec:\n"""
    rule += textwrap.indent(text, " " * 2) + "\n"

    if "condition" in r:
        rule += "{{- end }}" + "\n"

    # Write Configmap
    configmap_file = os.path.join(configmap_folder, r["name"] + ".yaml")
    with open(configmap_file, "w") as f:
        f.write(rule)

local addMixin = (import 'kube-prometheus/lib/mixin.libsonnet');

local certManagerMixin = addMixin({
  name: 'cert-manager',
  mixin: (import 'github.com/imusmanmalik/cert-manager-mixin/mixin.libsonnet')
  });

{ 'cert-manager-mixin-prometheusRule': certManagerMixin.prometheusRules }


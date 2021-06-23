local k8sMixinUtils = import 'github.com/kubernetes-monitoring/kubernetes-mixin/lib/utils.libsonnet';

local excludedAlerts = [
  'HighlyAvailableWorkloadIncorrectlySpread',
];

local removeRunbookUrl(rule) = rule {
  [if 'alert' in rule && ('runbook_url' in rule.annotations) && !std.member(excludedAlerts, rule.alert) then 'annotations']+: {
    runbook_url:: null,
  },
};

{
  removeRunbookUrl(o): {
    local filterRule(o) = o {
      [if (o.kind == 'PrometheusRule') then 'spec']+: k8sMixinUtils.mapRuleGroups(removeRunbookUrl),
    },
    [k]: filterRule(o[k])
    for k in std.objectFields(o)
  },
}

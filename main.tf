locals {
  alarm_name        = var.alarm_name != null ? var.alarm_name : format("%s-%s-%s-alarm", var.context.name_prefix, var.app_name, lower(var.metric_name))
  alarm_description = var.alarm_description != null ? var.alarm_name : format("This metric '%s' monitors for %s", var.metric_name, var.app_name)
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name                            = local.alarm_name
  alarm_description                     = local.alarm_description
  # action
  actions_enabled                       = var.actions_enabled
  alarm_actions                         = var.alarm_actions
  ok_actions                            = var.ok_actions
  #
  insufficient_data_actions             = var.insufficient_data_actions
  comparison_operator                   = var.comparison_operator
  evaluation_periods                    = var.evaluation_periods
  threshold                             = var.threshold
  unit                                  = var.unit
  datapoints_to_alarm                   = var.datapoints_to_alarm
  treat_missing_data                    = var.treat_missing_data
  evaluate_low_sample_count_percentiles = var.evaluate_low_sample_count_percentiles

  # conflicts with metric_query
  metric_name        = var.metric_name
  namespace          = var.namespace
  period             = var.period
  statistic          = var.statistic
  extended_statistic = var.extended_statistic

  dimensions = var.dimensions

  # conflicts with metric_name
  dynamic "metric_query" {
    for_each = var.metric_query
    content {
      id          = lookup(metric_query.value, "id")
      account_id  = lookup(metric_query.value, "account_id", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)
      period      = lookup(metric_query.value, "period", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }
  threshold_metric_id = var.threshold_metric_id

  tags_all = merge(var.context.tags, { AlarmName = local.alarm_name })

  lifecycle {
    ignore_changes = [tags]
  }

}

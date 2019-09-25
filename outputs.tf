output "schedule_name" {
  value = "${aws_cloudwatch_event_rule.rule_tracking_schedule.*.name}"
}

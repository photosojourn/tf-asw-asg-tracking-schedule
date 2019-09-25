/**
 * # tf-aws-asg-tracking-shedule
 * 
 * Terraform module that allows for the manipulation of the ASG TargetTrackingScaling
 * policy on a schedule.
 * 
 */
resource "aws_cloudwatch_event_rule" "rule_tracking_schedule" {
  count = "${length(var.schedule)}"
  name = "${lookup(var.schedule[count.index],"asg_name")}-${lookup(var.schedule[count.index],"schedule_name")}"
  description = "ASG Tracking Policy update Rule"
  schedule_expression = "${lookup(var.schedule[count.index],"schedule_expression")}"
}

resource "aws_cloudwatch_event_target" "target_tracking_schedule" {
  count = "${length(var.schedule)}"
  target_id = "${lookup(var.schedule[count.index],"asg_name")}-${lookup(var.schedule[count.index],"schedule_name")}"
  rule = "${element(aws_cloudwatch_event_rule.rule_tracking_schedule.*.name, count.index)}"
  arn = "${module.lambda.function_arn}"

  input = <<JSON
{
  "asg_name": "${lookup(var.schedule[count.index],"asg_name")}",
  "policy_name": "${lookup(var.schedule[count.index],"policy_name")}",
  "target": ${lookup(var.schedule[count.index],"target")}
}
JSON
}

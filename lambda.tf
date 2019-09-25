data "aws_iam_policy_document" "lambda" {
    statement {
        sid = "1"

        actions = [
            "autoscaling:DescribePolicies",
            "autoscaling:PutScalingPoliciy"
        ]

        resources = [
            "*"
        ]
    }

}

module "lambda" {
    source = "github.com/claranet/terraform-aws-lambda?ref=v0.10.0"

    function_name = "update_tracking_shedule"
    description = "Updates the TargetTrackingPolicy for an ASG"
    handler = "lambda.lambda_handler"
    runtime = "python3.6"
    timeout = 300
    reserved_concurrent_executions = 1

    source_path = "${path.module}/lambda.py"

    attach_policy = true
    policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count = "${length(var.schedule)}"
  statement_id = "AllowExecutionFromCloudWatch-${count.index}"
  action = "lambda:InvokeFunction"
  function_name = "${module.lambda.function_arn}"
  principal = "events.amazonaws.com"
  source_arn = "${element(aws_cloudwatch_event_rule.rule_tracking_schedule.*.arn, count.index)}"
}


### Resources
# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "route53_record" {
  zone_id = var.route53_record_parameter["zone_id"]
  
  name    = var.route53_record_parameter["name"]
  type    = var.route53_record_parameter["type"]

  alias {
    name                   = var.route53_record_parameter["alias_name"]
    zone_id                = var.route53_record_parameter["alias_zone_id"]
    evaluate_target_health = var.route53_record_parameter["alias_evaluate_target_health"]
  }
}

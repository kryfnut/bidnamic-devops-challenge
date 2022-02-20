#Retrieve Route 53 DNS and SSL Certificate records for tobisolomon.me domain name

data "aws_route53_zone" "tobisolomon_me" {
  name = "tobisolomon.me"
}

data "aws_acm_certificate" "tobisolomon_me" {
  domain   = "tobisolomon.me"
  statuses = ["ISSUED"]
}

#Create EKS Ingress that provisions Internet facing AWS ALB with SSL redirect rule.

resource "kubernetes_ingress" "bidnamic_default" {
  wait_for_load_balancer = true
  metadata {
    name = "bidnamic-alb"
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/group.name"           = "bidnamic"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{ \"Type\" : \"redirect\", \"RedirectConfig\" : { \"Protocol\" : \"HTTPS\", \"Port\" : \"443\", \"StatusCode\" : \"HTTP_301\" } }"
    }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
      }
    }
  }
}

#Create Route53 record - subdomain name for bidnamic and map it to the AWS ALB created by the EKS Ingress resource above

resource "aws_route53_record" "bidnamic_tobisolomon_me" {
  zone_id = data.aws_route53_zone.tobisolomon_me.zone_id
  name    = "bidnamic.${data.aws_route53_zone.tobisolomon_me.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_ingress.bidnamic_default.status.0.load_balancer.0.ingress.0.hostname]
}
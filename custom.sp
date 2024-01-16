
  #### Query to list Public Facing ALB not attached to WAFv2 

  query "alb_attached_to_waf" {
    sql = <<-EOQ
    with wafv2_with_alb as (
      select
        jsonb_array_elements_text(waf.associated_resources) as arn
      from
        aws_wafv2_web_acl as waf
    )
      select alb.arn as resource, 
      case 
        when alb.arn =  temp.arn then 'ok'
      else 'alarm'
      end as status,
      case 
        when alb.arn =  temp.arn then title || ' has associated WAF'
        else title || ' is not associated with WAF.'
      end as reason,
      region,
      account_id

    from aws_ec2_application_load_balancer as alb
      left join wafv2_with_alb  as temp on alb.arn =  temp.arn
    where "scheme" = 'internet-facing';
    EOQ
  }


#### Control construct defines structure and interface for queries that draw a specific conclusion (e.g. 'OK', 'Alarm') about each row

  control "alb_attached_to_waf" { 
    title       = "Public facing ALB are protected by AWS Web Application Firewall v2 (AWS WAFv2)"
    description = "Ensure public facing ALB are protected by AWS Web Application Firewall v2 "
    query       = query.alb_attached_to_waf
    }
  


#### Benchmar construct provides a mechanism for grouping controls into control benchmarks

  benchmark "bpost_custom" {
    title       = "Architecture Guardrails"
    description = "Application Load Balancer Architecture Guardrails"
    children = [
      control.alb_attached_to_waf
    ]
 }

output "aws_managed_ad_DNS_ips" {
  value = module.ad.aws_managed_ad_output.dns_ip_addresses
}
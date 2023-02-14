output "id" {
  value       = module.vpc.vpc
  description = "The ID of the VPC."
}

output "tags" {
  value       = module.vpc.vpc.tags_all
  description = "A mapping of tags to assign to the resource."
}

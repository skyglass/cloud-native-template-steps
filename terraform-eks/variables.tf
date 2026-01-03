# Use curl http://checkip.amazonaws.com to get your public IP address

variable "ingress_cidrs" {
    description = "List of CIDR blocks that can access the EKS cluster and Ingress"
    type    = list(string)
    default = ["71.198.43.41/32"]
}

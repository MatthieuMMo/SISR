variable "node_name" {
  description     = "proxmox nodes names"
  type            = list(string)
  default         = [
    "hv-epyc-02",
    "hv-r630-02",
    "hv-r630-01",
  ]
}

variable "vmids" {
  description     = "VMIDs"
  type            = list(string)
  default         = [
    "2520",
    "2521",
  ]
}

variable "ips" {
  description     = "IPs"
  type            = list(string)
  default         = [
    "33.0.0.5/10",
    "33.0.0.4/10",
  ]
}

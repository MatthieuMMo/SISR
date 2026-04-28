variable "vmids" {
  description     = "VMIDs"
  type            = list(string)
  default         = [
    "2000",
    "2001",
    "2002",
  ]
}

variable "ips" {
  description     = "IPs"
  type            = list(string)
  default         = [
    "192.168.20.100/10",
    "192.168.20.101/10",
    "192.168.20.102/10",
  ]
}

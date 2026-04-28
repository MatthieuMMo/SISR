terraform {
	required_providers {
		proxmox = { 
			source = "Telmate/proxmox"
			version = "3.0.2-rc07"
		}
	}
}

provider "proxmox" {
  pm_tls_insecure     = true
  pm_api_url          = "https://172.16.127.64:8006/api2/json"
  pm_parallel         = "2"
  pm_debug            = true
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "080185b7-8d66-4144-b86f-2c0fa3cfcbf0"
}

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
  pm_api_url          = "https://172.16.127.63:8006/api2/json"
  pm_parallel         = "2"
  pm_debug            = true
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "2aa011c2-fab8-42e0-b782-6a99a1918345"
}

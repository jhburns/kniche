// Configure the Vultr provider.
// Alternatively, export the API key as an environment variable: `export VULTR_API_KEY=<your-vultr-api-key>`.
provider "vultr" {
  api_key = "KEHHILY6FM5P272CCGX3YKIXOQI4AUR2WR3A"
}

// Find the ID of the Silicon Valley region.
data "vultr_region" "silicon_valley" {
  filter {
    name   = "name"
    values = ["Silicon Valley"]
  }
}

// Find the ID for CoreOS Container Linux.
data "vultr_os" "container_linux" {
  filter {
    name   = "name"
    values = ["Ubuntu 19.04 x64"] // gotten by 'curl https://api.vultr.com/v1/os/list'

  }
}

// Find the ID for a starter plan.
data "vultr_plan" "starter" {
  filter {
    name   = "price_per_month"
    values = ["5.00"]
  }

  filter {
    name   = "ram"
    values = ["1024"]
  }
}

// Find the ID of an existing SSH key.
data "vultr_ssh_key" "premade" {
  filter {
    name   = "name"
    values = ["Laptob"]
  }
}

// Create a Vultr virtual machine.
resource "vultr_instance" "example" {
  name              = "example"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  os_id             = "${data.vultr_os.container_linux.id}"
  ssh_key_ids       = ["${data.vultr_ssh_key.premade.id}"]
  hostname          = "example"
  tag               = "container-linux"
  firewall_group_id = "${vultr_firewall_group.example.id}"
}

// Create a new firewall group.
resource "vultr_firewall_group" "example" {
  description = "example group"
}

// Add a firewall rule to the group allowing SSH access.
resource "vultr_firewall_rule" "ssh" {
  firewall_group_id = "${vultr_firewall_group.example.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
}
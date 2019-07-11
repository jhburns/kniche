// Configure the Vultr provider.
// Alternatively, export the API key as an environment variable: `export VULTR_API_KEY=<your-vultr-api-key>`.
provider "vultr" {
  api_key = "K7K37WTS43MK3KWA4HWG7BQQ6BVGH6HE6QRQ" // Move this to enviroment
}

// Find the snapshot ID for a Kubernetes master.
data "vultr_snapshot" "master" {
  description_regex = "master"
}


data "vultr_snapshot" "entry" {
  description_regex = "entry"
}

data "vultr_snapshot" "worker" {
  description_regex = "worker"
}

// Find the ID of the Silicon Valley region.
data "vultr_region" "silicon_valley" {
  filter {
    name   = "name"
    values = ["Silicon Valley"]
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


// Create a Vultr virtual machine cluster.
resource "vultr_instance" "master" {
  name              = "master"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  snapshot_id       = "${data.vultr_snapshot.master.id}"
  hostname          = "master"
  tag               = "k3s-master"
  firewall_group_id = "${vultr_firewall_group.example.id}"
}

resource "vultr_instance" "entry" {
  name              = "entry"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  snapshot_id       = "${data.vultr_snapshot.entry.id}"
  hostname          = "entry"
  tag               = "k3s-worker-entry"
  firewall_group_id = "${vultr_firewall_group.example.id}"
}

resource "vultr_instance" "worker" {
  name              = "worker"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  snapshot_id       = "${data.vultr_snapshot.worker.id}"
  hostname          = "worker"
  tag               = "k3s-worker"
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


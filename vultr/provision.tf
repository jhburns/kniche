// Configure the Vultr provider.
// Alternatively, export the API key as an environment variable: `export VULTR_API_KEY=<your-vultr-api-key>`.
provider "vultr" {
  api_key = "K7K37WTS43MK3KWA4HWG7BQQ6BVGH6HE6QRQ" // Move this to enviroment
}

provider "vplus" {
  api_key = "K7K37WTS43MK3KWA4HWG7BQQ6BVGH6HE6QRQ"
}

data "vplus_reserved_ip" "entry" {
  name = "entry"
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
  firewall_group_id = "${vultr_firewall_group.others.id}"
}

resource "vultr_instance" "entry" {
  name              = "entry"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  snapshot_id       = "${data.vultr_snapshot.entry.id}"
  reserved_ip       = "${data.vplus_reserved_ip.entry.id}"
  hostname          = "entry"
  tag               = "k3s-worker-entry"
  firewall_group_id = "${vultr_firewall_group.entry_worker.id}"
}

resource "vultr_instance" "worker" {
  name              = "worker"
  region_id         = "${data.vultr_region.silicon_valley.id}"
  plan_id           = "${data.vultr_plan.starter.id}"
  snapshot_id       = "${data.vultr_snapshot.worker.id}"
  hostname          = "worker"
  tag               = "k3s-worker"
  firewall_group_id = "${vultr_firewall_group.others.id}"
}


// Creates 4 firewall groups, with a lot of redundancy due to the limitations of HCL
resource "vultr_firewall_group" "entry_worker" {
  description = "entry worker group, with ssh"
}

resource "vultr_firewall_rule" "entry_ssh" {
  firewall_group_id = "${vultr_firewall_group.entry_worker.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "vultr_firewall_rule" "entry_web" {
  firewall_group_id = "${vultr_firewall_group.entry_worker.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "vultr_firewall_rule" "entry_websecure" {
  firewall_group_id = "${vultr_firewall_group.entry_worker.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "vultr_firewall_group" "entry_worker_no_ssh" {
  description = "entry worker group, without ssh"
}

resource "vultr_firewall_rule" "entry_web_no_ssh" {
  firewall_group_id = "${vultr_firewall_group.entry_worker_no_ssh.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "vultr_firewall_rule" "entry_websecure_no_ssh" {
  firewall_group_id = "${vultr_firewall_group.entry_worker_no_ssh.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "vultr_firewall_group" "others" {
  description = "other servers group, with ssh"
}


resource "vultr_firewall_rule" "other_ssh" {
  firewall_group_id = "${vultr_firewall_group.others.id}"
  cidr_block        = "0.0.0.0/0"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "vultr_firewall_group" "others_no_ssh" {
  description = "other servers group, without ssh"
}
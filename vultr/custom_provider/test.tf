provider "vplus" {
  api_key = "K7K37WTS43MK3KWA4HWG7BQQ6BVGH6HE6QRQ"
}

data "vplus_reserved_ip" "my-server" {
  name = "test"
}
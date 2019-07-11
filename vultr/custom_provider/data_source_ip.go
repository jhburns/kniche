package main

import (
    "fmt"

	"github.com/JamesClonk/vultr/lib"
	"github.com/hashicorp/terraform/helper/schema"
)

func dataSourceIP() *schema.Resource {
	return &schema.Resource{
		Read: resourceServerRead,

		Schema: map[string]*schema.Schema{
			"region_id": {
				Type:       schema.TypeInt,
				Computed:   true,
			},

			"type": {
				Type:       schema.TypeString,
				Computed:   true,
			},

            "attached_id": {
                Type:       schema.TypeString,
                Computed:   true,
            },

			"name": {
				Type:       schema.TypeString,
				Required:   true,
			},

		},
	}
}

func resourceServerRead(d *schema.ResourceData, m interface{}) error {
    client := m.(*Client)

    name, nameOk := d.GetOk("name")

    if !nameOk {
        return fmt.Errorf(" %q must be provided", "name")
    }

    ips, err := client.ListReservedIP()
    if err != nil {
        return fmt.Errorf("Error getting reserved IP addresses: %v", err)
    }

    if len(ips) < 1 {
        return fmt.Errorf("Requesting reserved IPs found none, check that some exist")
    }

    var resIP lib.IP
    found := false
    for _, ip := range ips {
        if ip.Label == name {
            resIP = ip
            found = true
            break
        }
    }

    if !found {
        return fmt.Errorf("Reserved IP address matching that label not found.")
    }

    d.SetId(resIP.Subnet)
    d.Set("region_id", resIP.RegionID)
    d.Set("type", resIP.IPType)
    d.Set("attached_id", resIP.AttachedTo)
    d.Set("name", resIP.Label)

	return nil
}

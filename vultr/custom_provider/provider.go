package main

import (
	"time"

	"github.com/JamesClonk/vultr/lib"
	"github.com/hashicorp/terraform/helper/schema"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"api_key": {
				Type:        schema.TypeString,
				Optional:    true,
				DefaultFunc: schema.EnvDefaultFunc("VULTR_API_KEY", nil),
				Description: "A key needed to interact with the Vultr API.",
			},
		},

		DataSourcesMap: map[string]*schema.Resource{
			"vplus_reserved_ip": dataSourceIP(),
		},

		ConfigureFunc: setupKey,
	}
}

func setupKey(d *schema.ResourceData) (interface{}, error) {
	apiKey := d.Get("api_key").(string)

	client := Client{lib.NewClient(apiKey, &lib.Options{RateLimitation: 500 * time.Millisecond})}

	return &client, nil
}

type Client struct {
	*lib.Client
}

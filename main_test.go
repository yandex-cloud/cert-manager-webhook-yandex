package main

import (
	"github.com/jetstack/cert-manager/test/acme/dns"
	"os"
	"testing"
)

var (
	zone = os.Getenv("TEST_ZONE_NAME")
)

func TestRunsSuite(t *testing.T) {
	fixture := dns.NewFixture(&yandexCloudDNSSolver{},
		dns.SetResolvedZone(zone),
		dns.SetAllowAmbientCredentials(false),
		dns.SetManifestPath("testdata/yandex-cloud-dns"),
		dns.SetStrict(true),
	)

	fixture.RunConformance(t)
}

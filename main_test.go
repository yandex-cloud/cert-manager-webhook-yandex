package main

import (
	"github.com/cert-manager/cert-manager/test/acme"
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

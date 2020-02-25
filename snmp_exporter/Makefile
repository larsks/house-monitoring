all: snmp.yml

snmp.yml: generator.yml
	podman run --rm -v $(PWD):/opt prom/snmp-generator

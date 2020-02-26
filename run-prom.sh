#!/bin/bash

podman pod inspect prom >& /dev/null ||
podman pod create -n prom \
	-p 127.0.0.1:3000:3000 \
	-p 127.0.0.1:8008:8008 \
	-p 127.0.0.1:9116:9116 \
	-p 127.0.0.1:9090:9090 \
	\
	-p 6343:6343/udp

podman container inspect prom-main >& /dev/null ||
podman run -d --name prom-main \
	--pod prom \
	-v $PWD/prometheus:/etc/prometheus \
	-v prom-data:/prometheus \
	prom/prometheus

podman container inspect prom-snmp >& /dev/null ||
podman run -d --name prom-snmp \
	--pod prom \
	-v $PWD/snmp_exporter:/etc/snmp_exporter \
	prom/snmp-exporter

podman container inspect prom-grafana >& /dev/null ||
podman run -d --name prom-grafana \
	--pod prom \
	-v $PWD/grafana:/etc/grafana/provisioning \
	-v grafana-data:/var/lib/grafana \
	grafana/grafana

podman container inspect prom-sflow >& /dev/null ||
podman run -d --name prom-sflow \
	--pod prom \
	sflow/prometheus -Dsnmp.ifname=yes

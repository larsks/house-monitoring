#!/bin/bash

container() {
	cname=$1
	shift

	if podman container inspect "$cname" >& /dev/null; then
		echo "Container $cname is already running"
		return
	fi

	echo -n "Starting container $cname: "
	podman container run \
		--pod prom \
		--name "$cname" -d \
		"$@"
}

podman pod inspect prom >& /dev/null ||
podman pod create -n prom \
	-p 127.0.0.1:3000:3000 \
	-p 127.0.0.1:8008:8008 \
	-p 127.0.0.1:9116:9116 \
	-p 127.0.0.1:9090:9090 \
	\
	-p 6343:6343/udp

container prom-main \
	-v $PWD/prometheus:/etc/prometheus \
	-v prom-data:/prometheus \
	prom/prometheus

container prom-snmp \
	-v $PWD/snmp_exporter:/etc/snmp_exporter \
	prom/snmp-exporter

container prom-grafana \
	-v $PWD/grafana:/etc/grafana/provisioning \
	-v grafana-data:/var/lib/grafana \
	-e GF_INSTALL_PLUGINS=briangann-gauge-panel,grafana-piechart-panel \
	grafana/grafana

container prom-sflow \
	sflow/prometheus -Dsnmp.ifname=yes

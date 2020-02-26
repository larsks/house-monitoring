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
		--name "$cname" -d -l podname=Prom \
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
	--pod prom \
	-v $PWD/prometheus:/etc/prometheus \
	-v prom-data:/prometheus \
	prom/prometheus

container prom-snmp \
	--pod prom \
	-v $PWD/snmp_exporter:/etc/snmp_exporter \
	prom/snmp-exporter

container prom-grafana \
	--pod prom \
	-v $PWD/grafana:/etc/grafana/provisioning \
	-v grafana-data:/var/lib/grafana \
	grafana/grafana

container prom-sflow \
	--pod prom \
	sflow/prometheus -Dsnmp.ifname=yes

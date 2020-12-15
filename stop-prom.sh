#!/bin/bash

podman stop prom-{grafana,snmp,main}
podman rm prom-{grafana,snmp,main}

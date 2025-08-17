#!/bin/bash
#
# Generates snapshots for the VanessaGames project.

SNAPSHOT_TESTING="record"

SNAPSHOT_DEVICE_SCALE=2

mise exec -- tuist test --path VanessaGames ClausyTheCloud --no-selective-testing --device "iPhone 16 Pro" --os "18.6"

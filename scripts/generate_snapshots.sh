#!/bin/bash
#
# Generates snapshots for the VanessaGames project.

SNAPSHOT_TESTING="record"

mise exec -- tuist test --path VanessaGames

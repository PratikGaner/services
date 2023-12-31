#!/bin/bash
# /********************************************************************************
# * Copyright (c) 2022 Contributors to the Eclipse Foundation
# *
# * See the NOTICE file(s) distributed with this work for additional
# * information regarding copyright ownership.
# *
# * This program and the accompanying materials are made available under the
# * terms of the Apache License 2.0 which is available at
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * SPDX-License-Identifier: Apache-2.0
# ********************************************************************************/
# shellcheck disable=SC2086

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

GEN_DIR="." # "./gen_proto"

[ -d "$GEN_DIR" ] || mkdir -p "$GEN_DIR"

DATABROKER_PROTO="$SCRIPT_DIR/../proto"

if [ ! -d "$DATABROKER_PROTO" ]; then
	echo "Warning! Can't find DataBroker proto dir in: $DATABROKER_PROTO"
	exit 1
fi

# make sure deps are installed
echo "# Installing requirements-dev.txt ..."
pip3 install -q -r requirements-dev.txt
#pip3 install -q -r requirements.txt

set -xe
#protoc-gen-mypy \
PROTO_FILES=$(find "$DATABROKER_PROTO" -name '*.proto')

echo "# Generating grpc stubs from: $DATABROKER_PROTO ..."
python3 -m grpc_tools.protoc \
	--python_out="$GEN_DIR" \
	--grpc_python_out="$GEN_DIR" \
	--proto_path="$DATABROKER_PROTO" \
	--mypy_out="$GEN_DIR" \
	$PROTO_FILES
#set +x

echo "# Ensure each generated folder contains an __init__.py ..."

# Get root package names (unique)
# shellcheck disable=SC2068 # Double quotes don't work with grep
ROOT_PACKAGES=$(grep -Poshr "^package[[:space:]]+\K[_0-9A-Za-z]+" $PROTO_FILES | sort -u)
ROOT_DIRS=""
for p in $ROOT_PACKAGES; do
	ROOT_DIRS="$GEN_DIR/$p $ROOT_DIRS"
done

# Recursively add __init__.py files
find $ROOT_DIRS -type d -exec touch {}/"__init__.py" \;


echo "# Generated files:"
find $ROOT_DIRS -type f -name '*.py'

#echo "# Replacing packages in $GEN_DIR"
#find "$GEN_DIR" -type f -name '*.py' -print -exec sed -i 's/^from sdv.databroker.v1/from gen_proto.sdv.databroker.v1/g' {} ';'
#find "$GEN_DIR" -type f -name '*.pyi' -print -exec sed -i 's/^import sdv.databroker.v1/import gen_proto.sdv.databroker.v1/g' {} ';'

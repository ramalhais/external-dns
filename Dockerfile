# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# builder image
ARG ARCH
FROM golang:1.17 AS builder
ARG ARCH

WORKDIR /sigs.k8s.io/external-dns

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
#RUN make test build.$ARCH
RUN make build.$ARCH

# final image
#FROM $ARCH/alpine:3.15
FROM alpine:3.15

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /sigs.k8s.io/external-dns/build/external-dns /bin/external-dns

# Run as UID for nobody since k8s pod securityContext runAsNonRoot can't resolve the user ID:
# https://github.com/kubernetes/kubernetes/issues/40958
USER 65534

ENTRYPOINT ["/bin/external-dns"]

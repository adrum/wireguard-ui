FROM docker.io/node:15-buster AS ui
RUN git clone https://github.com/EmbarkStudios/wg-ui.git
WORKDIR /ui
RUN cp /wg-ui/ui/package.json /wg-ui/ui/package-lock.json /ui/
RUN npm install
RUN cp -R /wg-ui/ui/* .
RUN npm run build

FROM docker.io/golang:latest AS build
WORKDIR /wg
RUN go get github.com/go-bindata/go-bindata/...
RUN go get github.com/elazarl/go-bindata-assetfs/...
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
COPY --from=ui /ui/dist ui/dist
RUN go-bindata-assetfs -prefix ui/dist ui/dist
RUN go install .

FROM linuxserver/wireguard:latest
COPY --from=build /go/bin/wireguard-ui /
ENTRYPOINT [ "/wireguard-ui" ]

FROM debian:buster-slim as builder

ARG snapcast_version=0.20.0
ARG boost_version=1_70_0
ENV HOST snapserver

RUN  apt-get update \
  && apt-get install -y wget ca-certificates git build-essential libasound2-dev libvorbisidec-dev libvorbis-dev libopus-dev libflac-dev libsoxr-dev alsa-utils libavahi-client-dev avahi-daemon expat debhelper
RUN  wget https://github.com/badaix/snapcast/archive/v${snapcast_version}.tar.gz \
  && tar -xzvf v${snapcast_version}.tar.gz
RUN  wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_${boost_version}.tar.gz \
  && tar -xzvf boost_${boost_version}.tar.gz
RUN  cd snapcast-${snapcast_version} \
  && fakeroot make -f debian/rules CPPFLAGS="-I/boost_${boost_version}" binary

FROM debian:buster-slim

ARG snapcast_version=0.20.0
ENV HOST snapserver

COPY --from=builder /snapclient_${snapcast_version}-1_arm64.deb /snapclient_${snapcast_version}-1_arm64.deb
RUN  dpkg -i snapclient_${snapcast_version}-1_arm64.deb \
  ;  apt-get update \
  && apt-get -f install -y \
  && rm -rf /var/lib/apt/lists/*
RUN /usr/bin/snapclient -v
ENTRYPOINT ["/bin/bash","-c","/usr/bin/snapclient -h $HOST"]

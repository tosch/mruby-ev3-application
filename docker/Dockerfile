FROM ev3dev/debian-stretch-armel-cross

RUN sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get install --yes --no-install-recommends \
  build-essential \
  ruby \
  git \
  g++ \
  bison \
  binutils

RUN sudo mkdir -p /opt/mruby /opt/app && sudo chown compiler:compiler /opt/mruby /opt/app
WORKDIR /opt/app

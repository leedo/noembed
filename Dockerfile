ARG PERL_VERSION=5.44.0

FROM ubuntu:latest AS builder

ARG PERL_VERSION

WORKDIR /opt/noembed

RUN apt-get update && apt-get -y install \
    curl \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    perl \
    cpanminus \
    libexpat1-dev \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm -nq Perl::Build
RUN perl-build -j4 $PERL_VERSION /opt/perl-$PERL_VERSION

ENV PATH="/opt/perl-${PERL_VERSION}/bin:${PATH}"

RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm -nq Carmel

COPY cpanfile cpanfile.snapshot /opt/noembed/

RUN carmel install
RUN carmel rollout

FROM ubuntu:latest AS noembed

ARG PERL_VERSION

WORKDIR /opt/noembed

ENV PATH="/opt/perl-${PERL_VERSION}/bin:${PATH}"

RUN apt-get update && apt-get -y install \
    libssl3t64 \
    libexpat1 \
    && rm -rf /var/lib/apt/lists/*

COPY . /opt/noembed
COPY --from=builder /opt/noembed/local /opt/noembed/local
COPY --from=builder /opt/perl-${PERL_VERSION} /opt/perl-${PERL_VERSION}

# The address to listen on; override it with docker run -e LISTEN=...
ENV LISTEN=:5006
# Shell form, so $LISTEN is filled in when the container starts; exec keeps
# plackup as PID 1, so it gets docker's stop signal.
CMD exec perl -Ilocal/lib/perl5 local/bin/plackup -E prod --server Starlet -Ilib --max-workers 15 --listen "$LISTEN" bin/noembed.psgi

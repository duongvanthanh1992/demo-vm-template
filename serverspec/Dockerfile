FROM ruby:3.1-bullseye

RUN gem install serverspec ed25519 bcrypt_pbkdf winrm

COPY serverspec /serverspec
WORKDIR /serverspec

ARG OS
ARG VERSION
ARG TARGET

COPY ${OS}/${VERSION} ./${TARGET}
COPY share ./${TARGET}/share
COPY spec_rsa /spec_rsa

ENTRYPOINT ["rake"]
CMD ["spec"]
# pull in builds from artifacts
FROM alpine AS puller
ARG TARGET_BRANCH \
  TARGET_REPO="stashapp/stash" \
  WORKFLOW_NAME="Build" \
  ARTIFACT_NAME="stash-linux"
WORKDIR /app
COPY app/pr-artifact.sh /app/pr-artifact.sh
RUN apk add --no-cache curl jq
RUN --mount=type=secret,id=GITHUB_TOKEN \
  sh /app/pr-artifact.sh
RUN unzip stash-linux.zip && chmod 755 stash-linux

# pull in prebuilt s6/alpine
FROM ghcr.io/feederbox826/stash-s6:alpine AS stash-s6
COPY --from=puller --chmod=755 /app/stash-linux /app/stash

# pull in prebuilt s6/hwaccel
FROM ghcr.io/feederbox826/stash-s6:hwaccel AS stash-s6-hwaccel
COPY --from=puller --chmod=755 /app/stash-linux /app/stash

# pull in prebuilt stashapp/stash
FROM ghcr.io/nerethos/stash:latest AS stashapp
COPY --from=puller --chmod=755 /app/stash-linux /usr/bin/stash

# pull in prebuilt nerethos/stash:latest
FROM stashapp/stash AS nerethos
COPY --from=puller --chmod=755 /app/stash-linux /usr/bin/stash
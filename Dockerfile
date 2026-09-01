FROM ghcr.io/cirruslabs/flutter:stable AS flutter
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN dart run build_runner build --delete-conflicting-outputs
ARG PUBLIC_BASE_URL=
RUN flutter build web --release \
  --dart-define=API_URL= \
  --dart-define=PUBLIC_BASE_URL=$PUBLIC_BASE_URL

FROM dart:stable AS server
WORKDIR /server
COPY server/pubspec.yaml ./
RUN dart pub get
COPY server/ ./
RUN dart pub get
RUN dart compile exe bin/server.dart -o /server/whimsical

FROM debian:bookworm-slim
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=flutter /app/build/web /app/web
COPY --from=server /server/whimsical /app/server
ENV WEB_ROOT=/app/web
ENV PORT=8080
EXPOSE 8080
CMD ["/app/server"]

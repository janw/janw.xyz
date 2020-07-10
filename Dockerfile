FROM klakegg/hugo:ext as build

WORKDIR /src

# Copy submodules content
COPY bootstrap/scss ./bootstrap/scss
COPY faicons/svgs ./faicons/svgs

# Copy local content
COPY config.yaml ./
COPY content ./content
COPY themes ./themes

# Build
RUN hugo -d build

FROM nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /src/build /usr/share/nginx/html

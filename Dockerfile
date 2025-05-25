FROM node:22 as node
FROM ruby:3.4.2

COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
  && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -fs /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  libvips-dev \
  postgresql-client \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libffi-dev \
  libxml2-dev \
  libxslt-dev \
  pkg-config \
  git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV RAILS_ENV=development
ENV NODE_ENV=development
ENV BUNDLE_JOBS=4
ENV BUNDLE_RETRY=3

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN gem update --system && \
    gem install bundler -v 2.6.7 && \
    bundle config set force_ruby_platform true && \
    bundle config set jobs "${BUNDLE_JOBS}" && \
    bundle config set retry "${BUNDLE_RETRY}" && \
    bundle install

COPY package.json yarn.lock ./
RUN yarn install

COPY . /myapp

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["bin/dev"]
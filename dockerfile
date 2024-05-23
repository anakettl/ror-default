FROM ruby:3.2.2

WORKDIR /app

COPY . .

RUN bundle install
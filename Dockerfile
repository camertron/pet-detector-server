FROM ruby:2.4

EXPOSE 9292

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN mkdir -p ~/workspace
RUN git clone -b better https://github.com/camertron/pet-detector.git ~/workspace/pet-detector

COPY ./Gemfile /usr/src/app/
COPY ./Gemfile.lock /usr/src/app/
RUN bundle install --jobs=3 --retry=3

COPY ./config.ru /usr/src/app
COPY ./lib /usr/src/app/lib

RUN mkdir -p /usr/src/app/tmp

CMD ["puma", "-p", "9292"]

FROM suddani/ruby_base

ADD . /app

RUN bundle install;

CMD /app/bin/run

FROM arxivvanity/pandoc@sha256:26ca78b42315db131195dd2b25f9a29565299bb3482cbcad3f4ea1801e4b96a5 as pandoc
FROM debian:stretch

# Official CDN throws 503s
RUN sed -i 's/deb.debian.org/mirrors.kernel.org/g' /etc/apt/sources.list

# LaTeX stuff first, because it's enormous and doesn't change much
RUN apt-get update -qq && apt-get install -qy \
  curl \
  gnupg2 \
  libgmp10 \
  pdf2svg \
  texlive \
  texlive-latex-extra

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -qy \
  ca-certificates \
  curl \
  nodejs \
  git-core \
  gnupg2 \
  python \
  python-pip \
  yarn


# pandoc
COPY --from=pandoc /root/.local/bin/pandoc /usr/local/bin/pandoc

# pandocfilter
RUN mkdir -p /app/pandocfilter
WORKDIR /app
COPY pandocfilter/requirements.txt /app/pandocfilter/
RUN pip install -r pandocfilter/requirements.txt

# server
COPY server/requirements.txt /app/server/
RUN pip install -r server/requirements.txt

# Node
WORKDIR /app
COPY package.json yarn.lock /app/
RUN yarn

ENV PYTHONUNBUFFERED=1
ENV PATH="/app/bin:${PATH}"

COPY . /app

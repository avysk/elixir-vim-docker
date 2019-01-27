FROM elixir:1.8.0-alpine AS builder

RUN apk add git wget

WORKDIR /tmp

# Build Elixir LS

RUN wget https://github.com/JakeBecker/elixir-ls/archive/v0.2.24.tar.gz && tar xzf v0.2.24.tar.gz && rm v0.2.24.tar.gz

WORKDIR elixir-ls-0.2.24
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN mix elixir_ls.release -o /tmp/release/.elixir-ls

### Gather vim plugins
RUN mkdir -p /tmp/plugins/pack/addons/start

# vim-elixir
RUN git clone https://github.com/elixir-editors/vim-elixir.git elixir.git
RUN mkdir -p /tmp/plugins/pack/addons/start/elixir
RUN cd elixir.git && git archive master | tar -x -C /tmp/plugins/pack/addons/start/elixir

# tagbar
RUN git clone https://github.com/majutsushi/tagbar.git tagbar.git
RUN mkdir -p /tmp/plugins/pack/addons/start/tagbar
RUN cd tagbar.git && git archive master | tar -x -C /tmp/plugins/pack/addons/start/tagbar

# mix
RUN git clone https://github.com/mattreduce/vim-mix mix.git
RUN mkdir -p /tmp/plugins/pack/addons/start/mix
RUN cd mix.git && git archive master | tar -x -C /tmp/plugins/pack/addons/start/mix

# alchemist
RUN git clone https://github.com/slashmili/alchemist.vim.git alchemist.git
RUN mkdir -p /tmp/plugins/pack/addons/start/alchemist
RUN cd alchemist.git && git archive master | tar -x -C /tmp/plugins/pack/addons/start/alchemist

# ale
RUN git clone https://github.com/w0rp/ale.git ale.git
RUN mkdir -p /tmp/plugins/pack/addons/start/ale
RUN cd ale.git && git archive master | tar -x -C /tmp/plugins/pack/addons/start/ale


FROM elixir:1.8.0-alpine AS elixir-vim
ARG USERNAME

RUN apk update && apk upgrade && apk add tmux vim git git-subtree ctags python && rm /var/cache/apk/*

RUN adduser -D ${USERNAME}

RUN mkdir /etc/elixir-vim
COPY files/startup.sh /etc/elixir-vim
COPY files/elixir-vim.sh /etc/elixir-vim
RUN chmod +x /etc/elixir-vim/startup.sh

RUN mkdir /elixir-vim
RUN touch /elixir-vim/not-configured
RUN chown -R ${USERNAME}.${USERNAME} /elixir-vim

WORKDIR /home/${USERNAME}

COPY files/vimrc .vimrc
COPY files/ctags .ctags

RUN mkdir -p .vim
COPY --from=builder /tmp/plugins .vim/

COPY --from=builder /tmp/release .

RUN mkdir /home/${USERNAME}/src && chown -R ${USERNAME}.${USERNAME} .

USER ${USERNAME}

RUN vim -c 'silent! helptags ALL' -c 'q' >/dev/null 2>&1

ENTRYPOINT /etc/elixir-vim/startup.sh

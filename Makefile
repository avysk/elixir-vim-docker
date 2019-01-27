USERNAME:=flamel
build:
	docker build . -t elixir-vim:latest --build-arg USERNAME=${USERNAME}


run:
	docker run --rm elixir-vim:latest

run2:
	mkdir -p ~/.elixir-vim && docker run -it --mount src="$$(dirname ~/.elixir-vim/.)",target=/elixir-vim,type=bind --rm elixir-vim:latest

run3:
	~/.elixir-vim/elixir-vim.sh

clean:
	rm -rf ~/elixir-vim-src
	rm -rf ~/.elixir-vim

.PHONY: build run

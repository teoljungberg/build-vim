install: clone compile

clone:
	@bin/clone

compile:
	@bin/compile

clean:
	rm -rf tmp/vim

lint:
	@bin/lint

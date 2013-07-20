
COFFEE := $(shell npm bin)/coffee
UGLIFY := $(shell npm bin)/uglifyjs

SRC_JS := src/node_setup.js src/untar.js src/frontend.js

.PHONY: all clean deps

all: deps demo.js mini-rt.tar listings.json

demo.js: $(SRC_JS)
	cat $(SRC_JS) | $(UGLIFY) -o $@

%.js: %.coffee
	$(COFFEE) -c $?

listings.json:
	$(COFFEE) tools/gen_dir_listings.coffee >$@

mini-rt.tar: tools/preload
	tar -c -T tools/preload -f $@

clean:
	@rm -f $(SRC_JS) demo.js listings.json mini-rt.tar

deps: vendor/classes/java/util/zip/DeflaterEngine.class
	@npm install

vendor/classes/java/util/zip/DeflaterEngine.class:
	@bash tools/setup.sh
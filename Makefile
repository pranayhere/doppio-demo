
# Warning: must have these installed via `npm install -g`
COFFEE := coffee
UGLIFY := uglifyjs

SRC_JS := src/node_setup.js src/untar.js src/frontend.js

.PHONY: all clean jcl

all: demo.js jcl mini-rt.tar listings.json

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

jcl: vendor/classes/java/util/zip/DeflaterEngine.class

vendor/classes/java/util/zip/DeflaterEngine.class:
	@bash tools/setup.sh
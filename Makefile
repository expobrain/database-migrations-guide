init:
	cargo install mdbook
	cargo install mdbook-linkcheck
	cargo install mdbook-open-on-gh

lint:
	mdbook-linkcheck -s

serve:
	mdbook serve

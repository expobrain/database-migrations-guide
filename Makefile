init:
	cargo install mdbook
	cargo install mdbook-linkcheck

lint:
	mdbook-linkcheck -s

serve:
	mdbook serve

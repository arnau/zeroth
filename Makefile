env:
	@cat .env | awk '{print "export " $$0}'
.PHONY: env

iex:
	iex --dot-iex .iex.aliased.exs -S mix
.PHONY: iex

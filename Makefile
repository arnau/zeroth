env:
	@cat .env | awk '{print "export " $$0}'
.PHONY: env

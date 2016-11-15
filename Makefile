zip:
	rm ca.cybera.MySql.zip || true
	zip -r ca.cybera.MySql.zip *

upload:
	murano package-import --exists-action u ca.cybera.MySql.zip

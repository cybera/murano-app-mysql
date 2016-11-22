zip:
	rm ca.cybera.MySQL.zip || true
	zip -r ca.cybera.MySQL.zip *

upload:
	murano package-import --exists-action u ca.cybera.MySQL.zip

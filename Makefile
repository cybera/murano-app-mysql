all: zip upload

zip:
	rm ca.cybera.MySQL.zip || true
	zip -r ca.cybera.MySQL.zip *

upload:
	murano package-import --is-public --exists-action u ca.cybera.MySQL.zip

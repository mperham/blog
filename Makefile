build:
	hugo -F

run:
	open http://localhost:1313/
	hugo serve -DF

theme:
	# update theme
	cd themes/minimal-bootstrap-hugo-theme
	git fetch origin
	git merge origin master

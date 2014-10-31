build:
	jekyll build

upload: build
	rsync -zr _site/ mikeperham.com:/var/www/blog/

build:
	jekyll build

upload: build
	rsync -zr _site/ mikeperham.com:/var/www/blog/

run:
	bundle exec jekyll server

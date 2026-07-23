all:
	echo "build source with mdbook"
	mdbook build

publish: all
	echo "copy website to this folder"
	rm -rf FontAwesome
	rm -rf css
	rm -rf fonts
	rm -rf misc
	rm -rf posts
	mv book/* .
	echo "done"
	ls -la

clean:
	rm -rf book

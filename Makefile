all:
        echo "build source with mdbook"
        mdbook build
        echo "copy website to this folder"
        mv book/* .
        echo "done"
        ls -la
#!/bin/sh

rm ChainReaction.love
zip -r ChainReaction.love */ *.lua > /dev/null && echo ".love built: ./ChainReaction.love"

if [ "$1" = "bin" ]; then
    cat "$(which love)" ChainReaction.love > ChainReaction.bin && echo "Binary built: ./ChainReaction.bin"
    chmod +x ChainReaction.bin
fi


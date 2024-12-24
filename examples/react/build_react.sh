#!/bin/bash

echo
echo "* Build React project..."

cd webui-react-example
npm install || exit
npm run build || exit
cd ..

echo
echo "* Embedding React's build files into 'vfs.odin'"

python3 vfs.py "./webui-react-example/build" "vfs.odin"

echo
echo "* Compiling 'main.odin' into 'react' using Odin build command..."

odin build .

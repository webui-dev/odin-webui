#!/bin/bash

echo
echo "* Build React project..."

cd webui-react-example
npm install || exit
npm run build || exit
cd ..


echo
echo "* Compiling 'main.odin' into 'react' using Odin build command..."

odin build .

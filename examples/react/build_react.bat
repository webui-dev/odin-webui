@echo off

echo.
echo * Build React project...

cd webui-react-example
call npm install
call npm run build
cd ..

echo.
echo * Embedding React's build files into 'vfs.odin'

python vfs.py "./webui-react-example/build" "vfs.odin"

echo.
echo * Compiling 'main.odin' into 'react.exe' using the odin build command...

odin build .

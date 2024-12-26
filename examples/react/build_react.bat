@echo off

echo.
echo * Build React project...

cd webui-react-example
call npm install
call npm run build
cd ..

echo.


echo.
echo * Compiling 'main.odin' into 'react.exe' using the odin build command...
echo * Embedding React's build files into 'vfs.odin'

odin build .


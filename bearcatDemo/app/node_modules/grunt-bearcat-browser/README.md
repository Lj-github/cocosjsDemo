# grunt-bearcat-browser

## Getting Started

```shell
npm install grunt-bearcat-browser --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-bearcat-browser');
```

## The "bearcat_browser" task

### Overview
In your project's Gruntfile, add a section named `bearcat_browser` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  bearcat_browser: {
    options: {
      // Task-specific options go here.
    },
    your_target: {
      // Target-specific file lists and/or options go here.
    },
  },
});
```

### Options

#### options.dest
Type: `String`
Default value: `bearcat-bootstrap.js`

the ***bearcat-bootstrap.js*** generated path  

#### options.context
Type: `String`
Default value: `context.json`

the ***context.json*** file used for browser(client) path  

#### options.config
Type: `String`
Default value: `pwd/config`

config directory path

#### options.env
Type: `String`
Default value: `dev`

setup env

### Usage Examples

```js
grunt.initConfig({
   bearcat_browser: {
      default: {
        dest: "bearcat-bootstrap.js",
        context: "client-context.json"
      }
    }
});
```

## License

(The MIT License)

Copyright (c) fantasyni and other contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
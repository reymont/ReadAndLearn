


## Addons
Addons are JavaScript modules that extend the Terminal prototype with new methods and attributes to provide additional functionality. There are a handful available in the main repository in the src/addons directory and you can even write your own, by using xterm.js' public API.

To use an addon, just import the JavaScript module and pass it to Terminal's applyAddon method:

```js
import { Terminal } from xterm;
import * as fit from 'xterm/lib/addons/fit/fit';


Terminal.applyAddon(fit);

var xterm = new Terminal();  // Instantiate the terminal
xterm.fit();                 // Use the `fit` method, provided by the `fit` addon
```

## 参考

1. https://www.npmjs.com/package/xterm
2. https://github.com/xtermjs/xterm.js
3. https://xtermjs.org/
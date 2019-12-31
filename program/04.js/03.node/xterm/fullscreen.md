https://xtermjs.org/docs/api/addons/fullscreen/


Addons / fullscreen
The fullscreen addon provides the toggleFullScreen method that makes the terminal occupy the full viewport and back.

⚠️ Attention: Do not forget to include addons/fullscreen/fullscreen.css!

import * as Terminal from 'xterm';
import * as fullscreen from 'xterm/lib/addons/fullscreen/fullscreen';

Terminal.applyAddon(fullscreen);  // Apply the `fullscreen` addon

var term = new Terminal();

term.open(document.getElementById('terminal-container'));  // Open the terminal in #terminal-container

term.toggleFullScreen();  // Now the terminal should occupy the full viewport
term.toggleFullScreen();  // Now the terminal should be back to normal
Methods
toggleFullScreen([fullscreen])
fullscreen - Boolean - Whether to set the terminal to fullscreen mode or not
Set or unset the terminal’s fullscreen mode according to the given argument. If no fullscreen argument was given, then invert the terminal’s fullscreen mode.

Example
var Terminal = require('xterm');

Terminal.loadAddon('fullscreen');  // Load the `fullscreen` addon

var term = new Terminal();

term.open(document.getElementById('terminal-container'));  // Open the terminal in #terminal-container

term.toggleFullScreen(true);  // Force terminal fullscreen mode
term.toggleFullScreen(false);  // Force removal of terminal's fullscreen mode

// ... user code ...
term.toggleFullScreen()  // Toggle the terminal's fullscreen state
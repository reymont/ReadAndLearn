

```js
// public/js/app.js
    var codePageCourante = $("[data-page]").attr("data-page");
    $('#' + codePageCourante + 'Nav').addClass('active');
    loading();

    if (codePageCourante == 'logs') {
        logs();
    }

function logs() {
    Terminal.applyAddon(attach);
    Terminal.applyAddon(fit);
    var term = new Terminal({
        useStyle: true,
        convertEol: true,
        screenKeys: false,
        cursorBlink: false,
        visualBell: false,
        colors: Terminal.xtermColors
    });

    term.open(document.getElementById('terminal'));
    term.fit();
    var id = window.location.pathname.split('/')[3];
    var host = window.location.origin;
    var socket = io.connect(host);
    // https://blog.csdn.net/h330531987/article/details/78257517
    socket.emit('attach', id, $('#terminal').width(), $('#terminal').height());

    socket.on('show', (data) => {
        term.write(data);
    });

    socket.on('end', (status) => {
        socket.disconnect();
    });
}

```
var page = require('webpage').create(),
    system = require('system'),
    address, output, chart_id;

var fs = require('fs');


if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: export_auto_chart.js url filename width height');
    phantom.exit(1);

} else {
    url = system.args[1];
    output = system.args[2];

    if (output.substr(output.length-1) != '/') output += '/';

    if (!fs.isWritable(output)) {
        console.log('Cannot write to '+output);
        phantom.exit();
    }

    page.zoomFactor = 1;
    page.viewportSize = { width: system.args[3], height: system.args[4] };

    page.open(url, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address! '+url);
            phantom.exit();
        } else {
            window.setTimeout(function () {
                page.render(output+"chart.png");
                phantom.exit();
            }, 500);

        }
    });
}

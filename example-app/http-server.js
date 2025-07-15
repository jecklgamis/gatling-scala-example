const http = require('http');

if (process.argv.length <= 2) {
    console.error("Requires port number");
    process.exit();
}

const port = process.argv[2];
const host = "0.0.0.0";

const server = http.createServer((req, res) => {
    let body = [];
    const requestLog = {
        type: "request",
        method: req.method,
        headers: req.headers,
        host: req.headers.host
    };

    req.on('data', chunk => body.push(chunk))
        .on('end', () => {
            body = Buffer.concat(body).toString();
            requestLog.body = body;
            console.log(JSON.stringify(requestLog));

            res.setHeader('X-Source', 'http-server.js');
            res.end(JSON.stringify({ ok: "true", body }));
        });
});

server.listen(port, () => {
    console.log(`HTTP server listening on http://${host}:${port}`);
});
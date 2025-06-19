import * as http from "http";

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("Hello, World!\n");
});

server.listen(8080, "0.0.0.0", () => {
  console.log("Server running at :8080");
});
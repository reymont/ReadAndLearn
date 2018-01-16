
http://outofmemory.cn/code-snippet/7350/ruby-achieve-single-chao-jiandan-http-server

require 'socket'

server = TCPServer.open 9000
puts "Listening on port 9000"

loop {
  client = server.accept()
  while((x = client.gets) != "\r\n")
    puts x
  end
  resp = "Here be dragons"
  headers = ["HTTP/1.1 200 OK",
             "Date: Tue, 14 Dec 2010 10:48:45 GMT",
             "Server: Ruby",
             "Content-Type: text/html; charset=iso-8859-1",
             "Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
  client.puts headers
  client.puts resp
  client.close
  puts "Request Handled"
}
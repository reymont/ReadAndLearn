netsh interface ip set dns "Local Area Connection" source=static addr=172.20.62.78
netsh interface ip set dns "Wireless Network Connection" source=static addr=172.20.62.78
ipconfig /flushdns
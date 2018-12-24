

# http://docs.ansible.com/ansible/latest/get_url_module.html

```yml
- name: Download foo.conf
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    mode: 0440

- name: Download file and force basic auth
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    force_basic_auth: yes

- name: Download file with custom HTTP headers
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    headers: 'key:value,key:value'

- name: Download file with check (sha256)
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: sha256:b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c

- name: Download file with check (md5)
  get_url:
    url: http://example.com/path/file.conf
    dest: /etc/foo.conf
    checksum: md5:66dffb5228a211e61d6d7ef4a86f5758

- name: Download file from a file path
  get_url:
    url: file:///tmp/afile.txt
    dest: /tmp/afilecopy.txt
```
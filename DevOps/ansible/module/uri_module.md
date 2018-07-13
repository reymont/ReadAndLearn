

# http://docs.ansible.com/ansible/latest/uri_module.html

```yml
- name: Check that you can connect (GET) to a page and it returns a status 200
  uri:
    url: http://www.example.com

# Check that a page returns a status 200 and fail if the word AWESOME is not
# in the page contents.
- uri:
    url: http://www.example.com
    return_content: yes
  register: webpage

- name: Fail if AWESOME is not in the page content
  fail:
  when: "'AWESOME' not in webpage.content"


- name: Create a JIRA issue
  uri:
    url: https://your.jira.example.com/rest/api/2/issue/
    method: POST
    user: your_username
    password: your_pass
    body: "{{ lookup('file','issue.json') }}"
    force_basic_auth: yes
    status_code: 201
    body_format: json

# Login to a form based webpage, then use the returned cookie to
# access the app in later tasks

- uri:
    url: https://your.form.based.auth.example.com/index.php
    method: POST
    body: "name=your_username&password=your_password&enter=Sign%20in"
    status_code: 302
    headers:
      Content-Type: "application/x-www-form-urlencoded"
  register: login

- uri:
    url: https://your.form.based.auth.example.com/dashboard.php
    method: GET
    return_content: yes
    headers:
      Cookie: "{{login.set_cookie}}"

- name: Queue build of a project in Jenkins
  uri:
    url: "http://{{ jenkins.host }}/job/{{ jenkins.job }}/build?token={{ jenkins.token }}"
    method: GET
    user: "{{ jenkins.user }}"
    password: "{{ jenkins.password }}"
    force_basic_auth: yes
    status_code: 201
```
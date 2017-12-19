

# https://stackoverflow.com/questions/39819378/ansible-get-current-target-hosts-ip-address



29
down vote
accepted
A list of all addresses is stored in a fact ansible_all_ipv4_addresses, a default address in ansible_default_ipv4.address.

```yaml
---
- hosts: localhost
  connection: local
  tasks:
    - debug: var=ansible_all_ipv4_addresses
    - debug: var=ansible_default_ipv4.address
Then there are addresses assigned to each network interface... In such cases you can display all the facts and find the one that has the value you want to use.
```
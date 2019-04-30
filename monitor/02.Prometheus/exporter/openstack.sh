openstack_exporter --config openstack.yml --port 9113 --interval 15
#°²×°python-keystoneclient
pip install python-keystoneclient
pip install git+git://github.com/gvauter/prometheus_openstack
pip install git+git://github.com/CanonicalLtd/prometheus-openstack-exporter.git
#µÇÂ½
curl -vk -XPOST -H "Content-Type: application/json" https://10.0.1.11:5000/v2.0/tokens -d'{"auth":{"passwordCredentials":{"username": "liyang", "password":"123456"}}}'|python -m json.tool
curl -vk -XPOST -H "Content-Type: application/json" https://10.0.1.11:5000/v2.0/tokens -d'{"auth":{"passwordCredentials":{"username": "liyang", "password":"123456"},"tenantName":"paas"}}'|python -m json.tool

keystone = client.Client(username='liyang', password='123456',tenant_name='paas', auth_url='https://10.0.1.11:5000/v2.0',insecure='true')

nova = nova_client.Client("2", username, password, 'paas', 'https://10.0.1.11:5000/v2.0',insecure='true')
from novaclient import client as nova_client
nova = nova_client.Client("2", "admin", "yihe@pro1_cisco", 'admin', 'https://10.0.1.11:5000/v2.0',insecure='true')

curl -vk -XGET https://10.0.1.11:5000/v2.0/servers -d'{"auth":{"passwordCredentials":{"username": "admin", "password":"yihe@pro1_cisco"},"tenantName":"admin"}}'|python -m json.tool
curl -L http://127.0.0.1:4010/version

curl -L http://127.0.0.1:4012/v2/keys
{"action":"get","node":{"dir":true,"nodes":[{"key":"/registry","dir":true,"modifiedIndex":6,"createdIndex":6},{"key":"/flannel","dir":true,"modifiedIndex":4,"createdIndex":4}]}}

curl -L http://127.0.0.1:4012/v2/keys/registry|python -m json.tool
#根据pods获取租户id
curl -L http://127.0.0.1:4012/v2/keys/registry/pods|python -m json.tool
#根据租户id获取详细的值
curl -L http://127.0.0.1:4012/v2/keys/registry/pods/716mo7m10myxdnfbgfpr3f3dh8npzk|python -m json.tool


http://192.168.1.71:4012/v2/keys/registry/services/specs/70hcc3nik3vkgobv1rd3nwaamyjqn6w


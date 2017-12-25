

# https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/


# Use Multiple Service Accounts.

# Every namespace has a default service account resource called default. 
# You can list this and any other serviceAccount resources in the namespace with this command:
$ kubectl get serviceAccounts
# You can create additional ServiceAccount objects like this:
$ cat > /tmp/serviceaccount.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
EOF
$ kubectl create -f /tmp/serviceaccount.yaml
# If you get a complete dump of the service account object, like this:
$ kubectl get serviceaccounts/build-robot -o yaml
# You can clean up the service account from this example like this:
$ kubectl delete serviceaccount/build-robot
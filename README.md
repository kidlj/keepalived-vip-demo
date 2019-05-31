### Demo

	$ kubectl label node keepalived-node1 type=worker
	$ kubectl label node keepalived-node2 type=worker

	$ kubectl create sa kube-keepalived-vip
	$ kubectl create -f ./role.yaml
	$ kubectl create -f ./role-binding.yaml
	$ kubectl create -f ./echo-demo-v1-deploy.yaml
	$ kubectl create -f ./configmap.yaml

	$ kubectl create -f ./vip-daemonset.yaml
	

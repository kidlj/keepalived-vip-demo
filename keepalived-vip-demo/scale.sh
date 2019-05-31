for i in `seq 1 100`; do
	kubectl scale deploy --replicas=5 echo-demo-v1
	echo "scaled to 5, sleep 15s."
	sleep 5
	kubectl scale deploy --replicas=1 echo-demo-v1
	echo "scaled to 1, sleep 10s."
	sleep 5
done

#!/bin/bash
set -e

# Get all kube-control-plane ASGs in the current account and region
asgs=$(aws autoscaling describe-auto-scaling-groups --output json | jq .AutoScalingGroups[].AutoScalingGroupName -r | grep kube-control-plane)

for asg in $asgs; do
  hooks=$(aws autoscaling describe-lifecycle-hooks --auto-scaling-group-name $asg --output json | jq '.LifecycleHooks[] | select (.LifecycleTransition=="autoscaling:EC2_INSTANCE_TERMINATING") | .LifecycleHookName' -r)

  for hook in $hooks; do
    echo "Delete Lifecycle hook $hook of ASG $asg ? <Ctrl+C> to abort"
    read
    aws autoscaling delete-lifecycle-hook --lifecycle-hook-name $hook --auto-scaling-group-name $asg
  done
done

# unset any AWS_DEFAULT_PROFILE as it will break aws-iam-auth
unset AWS_DEFAULT_PROFILE

nodes=$(kubectl get nodes -l node-role.kubernetes.io/master -o json | jq .items[].metadata.name -r)

for node in $nodes; do
    echo "Deploying upgrade job on $node..."

    cat <<'EOF' > _job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kubezero-upgrade
  namespace: kube-system
spec:
  template:
    spec:
      hostNetwork: true
      hostIPC: true
      hostPID: true
      containers:
      - name: busybox
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          cat <<'EOF' > /host/tmp/upgrade.sh
          #!/bin/bash -ex
          for l in $(cat /etc/environment); do
            export $l
          done
          my_ip=$(ec2metadata --local-ipv4)
          my_id=$(ec2metadata --instance-id)
          clusterName=$(yq r /etc/kubezero/kubezero.yaml clusterName)
          my_asg=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${my_id}" --output json | jq '.Tags[] | select(.Key=="aws:cloudformation:logical-id") | .Value' -r)
          
          [ $my_asg == "KubeControlAsgAZ1" ] && nodename="etcd0-$clusterName"
          [ $my_asg == "KubeControlAsgAZ2" ] && nodename="etcd1-$clusterName"
          [ $my_asg == "KubeControlAsgAZ3" ] && nodename="etcd2-$clusterName"
          zone_name=$(hostname -d)
          
          zone_id=$(aws route53 list-hosted-zones --query 'HostedZones[?Name==`'"$zone_name"'.`].Id' --output text | cut --delimiter="/" --fields=3)
          cat <<EOF2 > route53.json
          { "Changes": [ { "Action": "UPSERT", "ResourceRecordSet": { "Name": "${nodename}.${zone_name}", "Type": "A", "TTL": 30, "ResourceRecords": [ { "Value": "$my_ip" } ] } } ] }
          EOF2
          
          echo "Updating DNS entry for $nodename to $my_ip"
          aws route53 change-resource-record-sets --hosted-zone-id $zone_id --change-batch file://route53.json
           
          echo "Adding additional control shutdown commands"
          if [ ! -f /usr/local/sbin/drain_delete_node.sh ]; then
            cat <<EOF3 > /usr/local/sbin/drain_delete_node.sh
          #!/bin/bash -ex
          export LC_TYPE=en_US.UTF-8
          export KUBECONFIG=/root/.kube/config
          kubeadm reset phase update-cluster-status
          kubeadm reset phase remove-etcd-member
          EOF3
            chmod +x /usr/local/sbin/drain_delete_node.sh
            sed -e 's,/usr/local/sbin/backup_control_plane.sh&,/usr/local/sbin/drain_delete_node.sh,' -i /usr/local/sbin/cloudbender_shutdown.sh
          fi

          echo "Patching ClusterConfig to re-create new etcd server certificates"
          yq w /etc/kubezero/kubeadm/templates/ClusterConfiguration.yaml etcd.local.serverCertSANs[+] $nodename > /etc/kubernetes/kubeadm-recert.yaml
          yq w -i /etc/kubernetes/kubeadm-recert.yaml etcd.local.serverCertSANs[+] $nodename.$zone_name
          rm -f /etc/kubernetes/pki/etcd/server.*
          kubeadm init phase certs etcd-server --config=/etc/kubernetes/kubeadm-recert.yaml 2>/dev/null
          kill -s HUP $(ps -e | grep etcd | awk '{print $1}')
          echo "Waiting for etcd to accept connections again...might take 30s or more"
          while true; do
            etcdctl member list -w simple 1>/dev/null 2>&1 && break || true
            sleep 3
          done
          EOF
          chmod +x /host/tmp/upgrade.sh
          chroot /host bash -c /tmp/upgrade.sh
        volumeMounts:
        - name: host
          mountPath: /host
        securityContext:
          privileged: true
      volumes:
      - name: host
        hostPath:
          path: /
          type: Directory
      nodeSelector:
        kubernetes.io/hostname: __node__
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      restartPolicy: Never
EOF

    # set controller node
    sed -i -e "s/__node__/$node/" _job.yaml

    kubectl apply -f _job.yaml
    kubectl wait -n kube-system --timeout 300s --for=condition=complete job/kubezero-upgrade
    kubectl delete -f _job.yaml
done

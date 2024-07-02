alias awslb="aws elbv2 describe-load-balancers --load-balancer-arns"
alias awsasg="aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names"
alias awstgg="aws elbv2 describe-target-groups --names"
alias awscluster="aws ecs describe-clusters --clusters"
alias awscf="aws cloudfront get-distribution --id"
alias awscp="aws ecs describe-capacity-providers --capacity-providers"
alias awslt="aws ec2 describe-launch-template-versions --launch-template-name"
alias awstd="aws ecs describe-task-definition --task-definition"
alias awsl="aws elbv2 describe-listeners --load-balancer-arn"
alias awslr="aws elbv2 describe-rules --listener-arn"

aws-ssh() {
    instance_id=`aws ec2 describe-instances --filters 'Name=instance-state-code,Values=16' \
        | jq -r '[.Reservations[].Instances[] | select(.PlatformDetails? != "Windows")
            | {
                id: .InstanceId,
                name: [.Tags[]? | select(.Key=="Name")] | .[0] | (if .Value == null then "*" else .Value end),
                private_dns: .PrivateDnsName,
                az: .Placement.AvailabilityZone
                }] | sort_by(.name) | .[] | .name + "\t" + .id  + "\t" + .private_dns + "\t" + .az' \
        | column -t \
        | peco \
        | awk '{print $2}'`

    if [ -n "$instance_id" ]; then
        aws ec2-instance-connect send-ssh-public-key \
                    --instance-id $instance_id \
                    --instance-os-user ${SSH_USER:-ec2-user} \
                    --ssh-public-key file://~/.ssh/id_rsa.pub > /dev/null

        ssh $@ ${SSH_USER:-ec2-user}@$instance_id
    fi
}

aws-sso() {
    aws_profile=`aws configure list-profiles | sort | peco --prompt="AWS SSO Profile"`
    if [ -n "$aws_profile" ]; then
        aws sso login --profile $aws_profile
    fi
}
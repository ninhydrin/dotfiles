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
    instance_id=$(aws ec2 describe-instances --filters 'Name=instance-state-code,Values=16' \
        | jq -r '[.Reservations[].Instances[] | select(.PlatformDetails? != "Windows")
            | {
                id: .InstanceId,
                name: [.Tags[]? | select(.Key=="Name")] | .[0] | (if .Value == null then "*" else .Value end),
                private_dns: .PrivateDnsName,
                az: .Placement.AvailabilityZone
                }] | sort_by(.name) | .[] | .name + "\t" + .id  + "\t" + .private_dns + "\t" + .az' \
        | column -t \
        | peco \
        | awk '{print $2}')

    if [ -n "$instance_id" ]; then
        aws ec2-instance-connect send-ssh-public-key \
                    --instance-id "$instance_id" \
                    --instance-os-user "${SSH_USER:-ec2-user}" \
                    --ssh-public-key "file://$HOME/.ssh/id_rsa.pub" > /dev/null

        ssh "$@" "${SSH_USER:-ec2-user}@${instance_id}"
    fi
}

aws-sso() {
    # 引数があればそれを使用、なければpecoで選択
    if [ -n "$1" ]; then
        aws_profile="$1"
    else
        aws_profile="$(aws configure list-profiles | sort | peco --prompt="AWS SSO Profile")"
    fi

    if [ -n "$aws_profile" ]; then
        aws sso login --profile "$aws_profile"
    fi
}

aws-unset(){
    unset AWS_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION
    echo "Cleared AWS env vars."
}

aws-kurisu-user() {
    aws-unset

    # 環境変数が設定されているか確認
    # Set these in ~/.env.d/aws.env:
    #   export AWS_KURISU_ACCOUNT_ID="your-account-id"
    #   export AWS_KURISU_ROLE_NAME="your-role-name"
    #   export AWS_KURISU_SESSION_NAME="your-session-name"
    if [ -z "$AWS_KURISU_ACCOUNT_ID" ] || [ -z "$AWS_KURISU_ROLE_NAME" ]; then
        echo "Error: AWS configuration not found. Please set AWS_KURISU_* variables in ~/.env.d/aws.env"
        return 1
    fi

    local role_arn="arn:aws:iam::${AWS_KURISU_ACCOUNT_ID}:role/${AWS_KURISU_ROLE_NAME}"
    local session_name="${AWS_KURISU_SESSION_NAME:-kurisu-session}"

    local token
    if token="$(AWS_PROFILE=kurisu-login aws sts assume-role --role-arn "$role_arn" --role-session-name "$session_name")"; then
        export AWS_ACCESS_KEY_ID="$(echo "$token" | jq -r .Credentials.AccessKeyId)"
        export AWS_SECRET_ACCESS_KEY="$(echo "$token" | jq -r .Credentials.SecretAccessKey)"
        export AWS_SESSION_TOKEN="$(echo "$token" | jq -r .Credentials.SessionToken)"
        export AWS_DEFAULT_REGION=us-east-1
        echo Login Succeed until "$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$(echo "$token" | jq -r .Credentials.Expiration | sed "s/+00:00/+0000/")" +"%Y-%m-%d %H:%M:%S %Z" -v+9H)"
    else
        echo Login Failed.
    fi
}

# プロファイルの一時クレデンシャルを環境変数に流し込む
awsenv () {
    local profile="${1:-default}"

    # まずは CLI v2 の export-credentials（SSO/MFA対応の一時クレデンシャル）を試す
    # 例: aws configure export-credentials --profile yourprof --format env
    if aws configure export-credentials --profile "$profile" --format env >/dev/null 2>&1; then
        eval "$(aws configure export-credentials --profile "$profile" --format env)"
    else
        # うまくいかない場合（古いCLI等）は ~/.aws/credentials から直接取得
        export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile "$profile")"
        export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile "$profile")"
        # セッショントークンがある環境（MFA等）なら設定、無ければ消す
        local tok; tok="$(aws configure get aws_session_token --profile "$profile")"
        if [ -n "$tok" ]; then export AWS_SESSION_TOKEN="$tok"; else unset AWS_SESSION_TOKEN; fi
    fi

    # リージョンは必要なら
    local region; region="$(aws configure get region --profile "$profile")"
    if [ -n "$region" ]; then export AWS_DEFAULT_REGION="$region"; fi

    export AWS_PROFILE="$profile"
    echo "Switched AWS profile → $AWS_PROFILE"
}

lsec2 (){
    aws ec2 describe-instances \
    --query "Reservations[].Instances[].{ID:InstanceId, Name:Tags[?Key=='Name']|[0].Value}" \
    --output table \
    --filters "Name=instance-state-name,Values=running"
}

_aws_ec2_hosts() {
    local -a ids names

    while IFS=' ' read -r id name; do
        ids+=("$id")
        names+=("$name")
    done < <(
        aws ec2 describe-instances --output json |
            jq -r '
            .Reservations[].Instances[] |
            .InstanceId as $id |
            (
              (.Tags // [] | map(select(.Key=="Name"))[0].Value) // "-"
            ) as $name |
            "\($id) \($name)"
            '
        )
    compadd -d names "${ids[@]}"
}

compdef _aws_ec2_hosts ssh

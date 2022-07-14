#!/bin/bash

set -e

get_secret() {
  # get secret from k8s secret store for db and grafana user and password
  kubectl get secret "$1" -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
}

logger() {
  local msg="$1"
  local color="$2"
  local color_reset="\033[0m"
  local color_code="\033[${color}m"
  echo -e "${color_code}${msg}${color_reset}"
}

usage() {
  logger "Usage: ./terraform.sh [-h] [-a] [-d] [-e <env>]" 33
  logger "  -h: print this help message" 33
  logger "  -a: apply terraform configuration (cannot be used with -d)" 33
  logger "  -d: destroy terraform configuration (cannot be used with -a)" 33
  logger "  -e: environment to deploy to (must be 'dev' or 'prod')" 33
  exit 0
}

rm_state() {
  local targets=($(terraform state list | grep -E "kubernetes_persistent_volume.prom_pv|module.db.google_sql_user.default" | awk '$1~/[a-z]/{gsub("\\[.*",""); printf "''%s'' ", $1}'))
  if [ "${targets[*]}" != "" ]; then
    terraform state rm "${targets[@]}"
  fi
}

apply() {
  "${cmd[@]}"
  # for key in grafana app-pass-admin app-pass-user1; do
  #   get_secret "$key"
  # done

  logger "Applied terraform configuration" 34
  logger "Wait a few moments for the loadbalancer to propogate and check the services bellow" 34

  echo "--------------------------------------------------------------------------------"
  logger "Grafana URL   : $(terraform output -raw grafana_url)" 32
  logger "Grafana Login : $(terraform output -raw grafana_user)" 32
  logger "Grafana Pass  : $(terraform output -raw grafana_pass)" 32
  echo "--------------------------------------------------------------------------------"
  logger "Rails App" 32
  app_url=$(terraform output -raw app_url)
  logger "User URL      : ${app_url}profile/login" 35
  logger "User Login    : user1@fitbod.me" 35
  logger "User Pass     : $(terraform output -raw user1_pass)" 35
  echo ""
  logger "Admin URL     : ${app_url}admin/login" 36
  logger "Admin Login   : admin@example.com" 36
  logger "Admin Pass    : $(terraform output -raw admin_pass)" 36
  echo "--------------------------------------------------------------------------------"
}

destroy() {
  rm_state
  "${cmd[@]}"
}

run() {
  local action="$1"
  local env="$2"
  cmd=(terraform "$action" -var-file="config/tfvars/terraform.tfvars" -var-file="config/tfvars/$env.tfvars")
  if [ "$action" == "apply" ]; then
    logger "Deploying to $env environment" "32"
    cmd+=(-auto-approve)
    apply "${cmd[@]}"
  elif [ "$action" == "destroy" ]; then
    logger "Destroying $env environment" "35"
    rm_state
    cmd+=(-auto-approve)
    destroy "${cmd[@]}"
  else
    logger "Action must be 'apply' or 'destroy'" "31"
    usage
  fi
  exit

}

# -e is required

while getopts ":hade:" opt; do
  case $opt in
    h)
      usage
      ;;
    a)
      action="apply"
      ;;
    d)
      action="destroy"
      ;;
    e)
      if [ "$OPTARG" == "dev" ] || [ "$OPTARG" == "prod" ]; then
        env="$OPTARG"
      else
        logger "Environment must be 'dev' or 'prod'" "31"
      fi
      ;;
    \?)
      logger "Invalid option: -$OPTARG" "31"
      ;;
    :)
      logger "Option -$OPTARG requires an argument." "31"
      ;;
    *)
      logger 'Error in command line parsing' "31" >&2
      exit 1
      ;;
  esac
done

shift "$((OPTIND - 1))"

if [ "$action" = "" ]; then
  logger 'Missing action flag -a/-d' "31" >&2
  usage
  exit 1
fi

if [ "$env" = "" ]; then
  logger 'Missing environment option -e' "31" >&2
  usage
  exit 1
fi

run "$action" "$env"

#!/bin/sh


check() {
    # do a check on the playbook before starting
    ANSIBLE_ROLES_PATH=../../..
    if ! ansible-playbook --check crucible-playbook.yml ; then
        echo "Ansible error, halting"
        exit 1
    fi
}

start() {
    docker-compose up -d --build
}

stop() {
    docker-compose down
}

ACTION=${1}
shift

INSTANCE=${2:-crucible}
shift


case $ACTION in
    check)
        check
        echo Success!
        ;;
    update)
        mkdir -p roles
        ansible-galaxy install --roles-path ./roles -r requirements.yml
        ;;
    start)
        check
        start
        ;;
    stop)
        stop
        ;;
    restart)
        check
        stop
        start
        ;;
    shell)
        docker-compose exec $INSTANCE bash
        ;;
    log)
        docker-compose exec $INSTANCE journalctl -f
        ;;
    *)
        echo "Unknown action: ${ACTION}"
        exit 1
        ;;
esac

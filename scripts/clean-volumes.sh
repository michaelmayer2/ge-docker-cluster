docker volume ls | grep sge | awk '{print $2}' | xargs docker volume rm

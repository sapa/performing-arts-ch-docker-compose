Uses staticfloat/docker-webhook to listen to git push events using webhooks.
On push events, templates will be copied into a mounted metaphactory runtime data container.

Additionally, templates and other configuration data will be copied into a app volume, i.e. if such a app folder is exposed as volume by the metaphactory (```volumes: - /apps/my-app```).

```yaml
metaphactory-dev-webhook:
    container_name: "${COMPOSE_PROJECT_NAME}-metaphactory-dev-git-webhook" 
    restart: unless-stopped
    image: staticfloat/docker-webhook
    environment:
     - VIRTUAL_HOST=webhook-${COMPOSE_PROJECT_NAME}.${HOST_NAME} 
     - LETSENCRYPT_HOST=webhook-${COMPOSE_PROJECT_NAME}.${HOST_NAME}
     - LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
     - WEBHOOK_SECRET=webhook-secrect-token
     - WEBHOOK_HOOKS_DIR=/code/hooks
     - WEBHOOK_BRANCH_LIST=master
     - WEBHOOK_APP_DIRECTORY=my-app
     - WEBHOOK_GIT_REPOSITORY=https://github.com/{user}/{repository}.git
    expose:
     - 8080
    volumes_from:
     - metaphactory
    #optionally mount additional hook scripts
    #volumes:
    # /host/my-script.sh:/code/hooks/my-script.sh
    networks:
     - default
     - metaphactory_network
    depends_on:
     - metaphactory
```

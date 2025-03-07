# loonar-morpheus-docker

Loonar Cloud deployments with Docker for Morpheus Data Integrations

WIP

## Portainer stack

### Deploy

The command below will check if the supplied ports are available and the name given to the stack is also (compose_project_name). Change parameters values with your preferences.

```bash
./deploy.sh stacks/portainer COMPOSE_PROJECT_NAME=portainer PORTAINER_WEB_PORT=9000 PORTAINER_AGENT_PORT=8000 POSTGRES_USER=portainer POSTGRES_PASSWORD=changeme
```

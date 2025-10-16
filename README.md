# Infrastructure Documentation

## Quick Start

### Up

For running all infrastructure within single command, use:

```bash
$ docker compose --profile all up --build -d
```

### Restarting some service

For restarting single service with no downing entire compose, use:

Firstly, pull a new image for service, i.e. - `api`

```bash
$ docker compose pull api
```

And up the compose with providing name for this service

```bash
$ docker compose up -d api
```

---

TBD, for now - just config for docker compose that are not related to any service (third-party deps).

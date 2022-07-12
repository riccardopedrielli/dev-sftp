# dev-sftp

SFTP service for development and testing purposes.

## Prerequisites

Install [Docker](https://docs.docker.com/engine/install/)
and [Docker Compose](https://docs.docker.com/compose/install/).

The logging driver is set to `local`.  
Follow this guide to configure the docker daemon to use the
[local file logging driver](https://docs.docker.com/config/containers/logging/local/).

## Configuration

To set a custom configuration create a file in `~/.config/docker-dev-tools/dev-sftp/settings.env`
and add the variables to override.

Use `./servicectl.sh info` for the list of available variables and their values.

When setting paths, always use the unix slash `/` even on Windows.

> **Note:** `~` is an alias for the user's home directory.
>
> - Linux: `/home/<username>`
> - macOS: `/Users/<username>`
> - Windows: `C:/Users/<username>`
>
> The `${HOME}` variable is also available but can lead to compatibility issues, especially on Windows.

### Data persistence

By default the persistence directory is set to `~/.local/share/docker-dev-tools/dev-sftp`.

Any custom directory should be set in a path inside the user's home directory.
Setting it outside is not supported and, depending on the host platform, may not work.

There's no need to manually create directory, Docker Compose will take care if it.

## Usage

To manage the service, execute `./servicectl.sh <command>`.

| Command   | Arguments    | Description                                                             |
| :-------- | :----------- | :---------------------------------------------------------------------- |
| `up`      |              | Bring up the service.                                                   |
| `down`    |              | Bring down the service.                                                 |
| `prune`   |              | Bring down the service and delete the data.                             |
| `info`    |              | Show informations about the service: name, config, status.              |
| `logs`    |              | Show service's logs, takes the same arguments as `docker compose logs`. |
| `encrypt` | `<password>` | Print the `<password>` encrypted.                                       |

### Host

On Linux and macOS the services are available at `localhost`.

On Windows the services are available at the virtual machine's ip. Usually `192.168.99.100`,
can be inspected with `docker-machine ip`.

### Default ports

| Type        | Application      | Default port |
| :---------- | :--------------- | :----------: |
| SFTP server | `openssh-server` |    `2222`    |

### Default accounts

| User  | Password |
| :---- | :------- |
| `dev` | `dev`    |

### User management

It is advised to create a new `users.conf` file and set its path in `SFTP_USERS_FILE` variable in the `settings.env` file described in [Configuration](#configuration).

The users must be added one per line in one of the the following formats:

- `name:password:uid`
- `name:password:e:uid`

Use `e` as third field to indicate that the password is encrypted.

For example, the default user is defined as:

- `dev:dev:1000`

Using the same password, but encypted, it would become:

- `dev:$1$2NyNFvrG$Hj53mHXZBsuMmUPMPb6u41:e:1000`

The `uid` field is also the user home.  
In the former example, the absolute path of the user home would be `/home/1000`.  
If two users have the same `uid`, they will have the same home directory,
this is useful in case more users need to access the same files.  
Example:

```text
user1:pwd1:1000
user2:pwd2:1000
```

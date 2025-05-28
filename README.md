# thisisdevelopment/laravel-base

An opinionated base laravel install. 

## Install

```
composer create-project thisisdevelopment/laravel-base <dir>
```

Or alternatively if you don't have composer installed locally:

```
dir=<dir>
git clone https://github.com/thisisdevelopment/laravel-base $dir
cd $dir
rm -rf .git
./bin/dev init
```

## Folder structure

This is modeled after the domain oriented structure proposed by sticher.io:  https://stitcher.io/blog/laravel-beyond-crud-01-domain-oriented-laravel
The proposed structure is extended with the concept of modules, which are default implementations of generic domain code. 

The complete structure is

- `app` <= toplevel app dir, no code here
- `app/App/<app name>/` <= application specific code
- `app/Domain/<domain>` <= domain specific code
- `app/Domain/vendor/<domain>` <= generic domain code (managed by composer, for packages with type=laravel-domain) 
- `app/Module/<module>` <= module code (managed by composer, for packages with type=laravel-module) 
- `packages/<package>/` <= composer wil automatically pickup any packages in this directory. This allows to develop packages alongside your application (see [packages/README.md](packages/README.md)) 

It uses `oomphinc/composer-installers-extender` to install packages of type laravel-module/laravel-domain to the `app/Module` and `app/Domain/vendor` folders.  

## Docker compose support

This base install comes with a complete docker-compose setup out of the box. 
It assumes you have a working local docker install which allows access to docker for your own user.

To easily access the containers you should also run the `thisisdevelopment/docker-hoster` container (see https://github.com/thisisdevelopment/docker-hoster) to dynamically update your hosts file.

```
docker run --restart=unless-stopped -d \
    -v /var/run/docker.sock:/tmp/docker.sock \
    -v /etc/hosts:/tmp/hosts \
    thisisdevelopment/docker-hoster
```

## Dev script

To easily access the containers you should use the included `bin/dev` script.
This script allows for easy execution of composer etc inside your containers.

The supported commands are:

- `up`
- `down`
- `rm`
- `deploy`
- `logs`
- `php-cli`
- `composer`
- `artisan`
- `phpcs`
- `phpcbf`
- `phpunit`

## Coding standards

This base install enforces the `PSR-12` code standard. It does this by installing a git-hook which enforces this standard (by means of `phpcs`)

## SSL/HTTPS
### Linux
To enable HTTPs on (Ubuntu) Linux, the following steps need to be performed.
- generate local development certificate
- rename app-hostname.
- add nginx reverse proxy to docker-compose

To generate a certificate you'll need the tool `mkcert` (to generate the certificate) and `libnss3-tools` to automatically register this certificate in your browser (Firefox/Chrome).  e.g. `apt-get install mkcert libnss3-tools`.

When installed, we can generate the certificate by running the following commands from project root, where `app.services.docker` needs to be replaced with the value from your `.env`'s `APP_DOMAIN`.

``` shell
mkcert -key-file ./docker/services/app/certs/ssl.key -cert-file ./docker/services/app/certs/ssl.crt app.services.docker
```

Next, we need to add an additional service to the docker-stack, allowing us to use SSL.  If not present already, create a `docker-compose.override.yml` at project root, and add the following.
``` yml
services:
  nginx:
    image: nginx:latest
    hostname: $APP_DOMAIN
    depends_on:
      - app
    volumes:
      - ./docker/services/app/certs/:/etc/nginx/ssl
      - ./docker/services/app/nginx-ssl.conf:/etc/nginx/conf.d/app.services.docker.conf

  app:
    hostname: "" # this needs to be set to empty (or anything not APP_DOMAIN) to prevent collision with new nginx
```

Now you'll need to restart the entire stack with a `./bin/dev down && ./bin/dev up`.  At this point the app should be available through https on the original domain.

### Mac
Probably the easiest way to get https working is by using Orbstack using [these instructions](https://docs.orbstack.dev/features/https#https-for-containers).

### Environment
For both Linux and Mac you need to set `VITE_APP_ORIGIN` to a url that includes `https` in the `.env` file.:
- `VITE_APP_ORIGIN=https://${APP_DOMAIN}`

Everything _should_ work out of the box if you've followed the steps above, but you _might_ need to update these environment variables in your `.env` as well:
- `APP_HTTPS=true`
- `APP_DOMAIN=https://${APP_DOMAIN}`

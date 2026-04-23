# App source (not vendored in this repo)

The customer app `onthegoapp` is maintained in its own repository.

On a machine that needs the Docker build context (e.g. your home server), clone it into this path:

```bash
cd /path/to/homeserver
git clone https://github.com/ravenskys/onthegoapp.git apps/onthegoapp
```

Then deploy from `compose/customer-app` as documented in the build guide.

Sentry is a utility for managing your authorized keys and ssh configs.

It allows you to add authorized keys to your local machine, or to ssh
into and machine that you control and add keys.

You can

sentry authorize jonathan@staging <path to key file>
sentry remove jonathan@staging <path to key file>

this will add or remove jonathan's public ssh key to the staging server.

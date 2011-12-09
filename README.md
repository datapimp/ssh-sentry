Sentry allows you to manage your ssh access to various environments for
your development team.

Usage sentry [command] [options] 

Examples:
---

To initialize sentry on a server:

```
  sentry start from ~/.ssh/authorized_keys

To add or remove users from a host:

```
  sentry authorize jonathan on staging with ~/.ssh/id_rsa.pub
  sentry revoke jonathan on staging

To manage a remote ssh box with sentry:

```
  sentry manage remote sshuser@sshhost with ~/.ssh/id_rsa.pub

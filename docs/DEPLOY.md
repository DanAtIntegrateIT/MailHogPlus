Deploying MailHogPlus
=================

MailHogPlus is a fork of `mailhog/MailHog`. This document describes deployment for this fork, not upstream binary/package channels.

### Command line

You can run MailHogPlus locally from the command line.

    git clone <your-fork-url>
    cd MailHogPlus
    make deps
    go build -o MailHogPlus .
    ./MailHogPlus -h

To configure MailHogPlus, use the environment variables or command line flags
described in the [CONFIG](CONFIG.md).

### Using supervisord/upstart/etc

MailHogPlus can be started as a daemon using supervisord/upstart/etc.

See [this example init script](https://github.com/geerlingguy/ansible-role-mailhog/blob/master/templates/mailhog.init.j2)
and [this Ansible role](https://github.com/geerlingguy/ansible-role-mailhog) by [geerlingguy](https://github.com/geerlingguy).

If you want to run as a service on macOS/Linux, create a service wrapper around the built `MailHogPlus` binary.

### Docker

The example [Dockerfile](../Dockerfile) can be used to run MailHogPlus in a [Docker](https://www.docker.com/) container.

Build an image from this repository:

    docker build -t mailhogplus:local .
    docker run -d -p 1025:1025 -p 8025:8025 mailhogplus:local

To mount the Maildir to the local filesystem, you can use a volume:

    docker run -d -e "MH_STORAGE=maildir" -v $PWD/maildir:/maildir -p 1025:1025 -p 8025:8025 mailhogplus:local

### Elastic Beanstalk

You can deploy MailHogPlus using [AWS Elastic Beanstalk](http://aws.amazon.com/elasticbeanstalk/).

1. Open the Elastic Beanstalk console
2. Create a zip file containing the Dockerfile and MailHogPlus binary
3. Create a new Elastic Beanstalk application
4. Launch a new environment and upload the zip file

**Note** You'll need to reconfigure nginx in Elastic Beanstalk to expose both
ports as TCP, since by default it proxies the first exposed port to port 80 as HTTP.

If you're using in-memory storage, you can only use a single instance of
MailHogPlus. To use a load balanced EB application, use MongoDB backed storage.

To configure your Elastic Beanstalk MailHogPlus instance, either:

* Set environment variables using the Elastic Beanstalk console
* Edit the Dockerfile to pass in command line arguments

You may face restrictions on outbound SMTP from EC2, for example if you are
releasing messages to real SMTP servers.

### SaltStack

For deploying MailHogPlus using [SaltStack](https://github.com/saltstack/salt), there's a
[SaltStack Formula](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html)
available in [github.com/ssc-services/salt-formulas-public](https://github.com/ssc-services/salt-formulas-public/tree/master/mailhog).

# Classify

Once you've tested your Puppet code in a development environment, you can apply
it to any node in your Puppet infrastructure.

## Write a node declaration

To make things easy, we've set up a node called `webserver-test` with the
Puppet agent already installed. Puppet uses a special manifest called `site.pp`
to assign classes to nodes.

    vim /etc/puppetlabs/code/environments/production/manifests/init.pp

Create a new node declaration for the `webserver-test` node, and include your
`hello` class.

    node 'webserver-test' {
      include hello
    }

By default, Puppet runs every 30 minutes. To speed things up and see what's
going on as Puppet does it's work connect to the `webserver-test`.

    ssh root@webserver-test

And trigger a Puppet run.

    puppet agent -t

When the run is complete, disconnect from the server.

    exit

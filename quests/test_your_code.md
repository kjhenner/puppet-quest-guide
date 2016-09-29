# Test your code

Be clear about the difference between testing your code during development and
applying it on a system.

## Write examples

Defining a class tells Puppet what that class means, but doesn't tell it to do
anything with it. To test your class, you need to write an example manifest
where you'll tell puppet to apply it. Be sure you're in the modules directory.

    cd /etc/puppetlabs/code/environments/production/modules

Create a test manifest for `init.pp` in your `hello/examples` directory.

    vim hello/examples/init.pp

Use the 'include' syntax to tell Puppet you want to apply your `hello` class.

    include hello    

Use `puppet apply` to run your test.

    puppet apply hello/examples/init.pp

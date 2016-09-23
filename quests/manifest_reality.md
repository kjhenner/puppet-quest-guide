# Manifest reality

If you want a consistent way to manage your system, you need to save and
organize your resource declarations.

## Infrastructure as code

Open a new file to write your resource declaration:

    vim hello_puppet.pp

Type `i` to enter insert mode, and write out your resource declaration. Feel
free to replace the content with any message you like.

    resource { '/var/www/html/quest/hello_puppet.html':
      ensure  => file,
      content => "Hello from Puppetconf!"
    }

Now use the `puppet apply` command to tell puppet to apply your manifest.

    puppet apply hello_puppet.pp

Check out your new page!

Throwing resources into a manifest doesn't scale well. In the next quest, we'll
show you how to keep your code organized with classes.

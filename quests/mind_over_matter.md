# Mind over matter

Puppet can translate just about anything on your system into the resource
syntax. It can also apply the state described by the resource syntax back
onto the system you want to manage.

## Enforce your changes

Use the `puppet resource` tool to take another look at that file resource. This
time, pass in the `-e` flag to tell the tool you want to edit the resource

    puppet resource file /var/www/html/hello_puppet.html -e

In the text editor, type `i` to enter insert mode and change the value of the
`ensure` parameter from `absent` to `present`. Type `:wq` to save and exit the
editor.

You told Puppet that that file should exist. When Puppet saw that it wasn't
there, it went ahead and created it for you.

Because you didn't specify any content, the file is empty. Move on to the next
task and we'll show you how to set the file's content.

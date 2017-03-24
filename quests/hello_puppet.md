{% include '/version.md' %}

# Hello Puppet

## Quest objectives

- Get started with the basics: what is Puppet and what does it do?
- Install the Puppet agent on a new system.
- Understand Puppet's resources and the resource abstraction layer (RAL).

## Get started

> Any sufficiently advanced technology is indistinguishable from magic.

> - Arthur C. Clarke

This quest will begin your hands-on introduction to Puppet. We'll start by
installing the Puppet agent and learning some of the core ideas involved in
managing infrastructure with Puppet. Once the Puppet agent is installed on a
new system, you will use the `puppet resource` and `facter` tools to explore
the state of that system. Through these tools, you will learn about *resources*
and the fundamental units of information Puppet uses to manage a system.

Ready to get started? Run the following command on your Learning VM:

    quest begin hello_puppet

## What is Puppet?

Before getting into the details of how Puppet works and how to use it, let's
take a moment to review what Puppet is and why it's worth learning. When we
talk about Puppet, we're often using a short-hand to refer to an ecosystem of
tools and services you can use in concert to manage your infrastructure. The
rest of this guide will take a deeper dive into many of these components, but
for now, let's take a moment to review some of the key points that distinguish
Puppet's approach from the other tools you might use to manage your systems.

Put in the most general terms, Puppet is allows you to define a desired state
for all the systems in your infrastructure. Once that state is defined, Puppet
automates the process of getting your systems into that state and keeping them
there.

**Puppet is portable.** Its declarative language gives you a single syntax for
describing desired state across Windows and Unix-like systems, network devices,
and containers. This means you don't have to switch language and toolset every
time you start work on a new system. This also means that learning Puppet gives
you a skillset that can be carried over across projects and roles.

**Puppet is centralized.** With Puppet's master/agent architecture, there's no
need to connect to systems individually to make changes. Once the Puppet agent
service is running on a system, it will periodically establish a secure
connection to the Puppet master, fetch any Puppet code you've applied to it and
make any changes necessary to bring the system in line with the desired state
you described. The fact that centralized control is built in from Puppet's
foundations makes monitoring and compliance that much easier.

[**The Puppet Forge**](forge.puppet.com) is a repository of modules maintained
by Puppet and the Puppet community that give you everything you need to manage
common applicatons and services. The Forge has a wide range of modules to help
you manage everything from NTP and SQL Server to Minecraft. The base of well tested
and reviewed code means that you can get started puppetizing key aspects of your
infrastructure right out of the gate.

**Puppet connects you to the cutting edge.** Puppet provides a stable platform
for bringing new technologies into production. Integrations with Docker,
Kubernetes, Mesos and others let you engage with next generation software in a
way that's simple, reliable, and consistent.

## The Puppet agent

As we noted above, what we call "Puppet" is actually a variety of tools and
services that work together to help you manage and coordinate the systems in
your infrastructure. Though this ecosystem gives you a great degree of power
and control, the complexity can leave a new user wondering where to start. So
this was the first question we had to answer as we were putting together this
guide: "where do we begin?"

By introducing the Puppet agent and some of the command line tools included in
the agent installation, we hope to strike the right balance between the big
picture view of Puppet and the the bottom-up fundamentals. You'll be able to
understand the agent's role in the broader Puppet architecture, as well as the
details of how interacts with the system where it's installed.

The Puppet agent runs on each of the systems you want Puppet to manage. It
communicates with the central Puppet master server and makes any changes needed
to keep its system in line with the desired state. While the Puppet agent is
generally used as part of a master/agent architecture, it can also be used to
apply Puppet code locally. This independent use of the agent is often used to
quickly test code on a development system. We'll use it here to demonstrate
some of the core concepts of Puppet before moving on to a more complete
master/agent architecture and workflow in the next quest.

When you install the Puppet agent you also get a set of supporting tools. This
includes software like `facter` and the `puppet resource` command. We'll use
these tools from the command-line to view the state of the system in the same
way Puppet does. Understanding how the Puppet agent sees and modifies the state
of the system where it's running will be the foundation for everything else you
learn about Puppet.

## Agent installation

Though we're focusing on the Puppet agent in this quest, we'll be using it in
the context of the master/agent architecture we've set up on the Learning VM.
The Learning VM itself has the Puppet master pre-installed. For each quest, the
quest tool we created to guide you through these lessons will provide one or
more agent systems that will connect to the master.

For this quest, we've prepared a fresh system where you can install the Puppet
agent and explore some of the tools it provides. The Puppet master hosts an
install script you can easily run from any system that can connect to it.

<div class = "lvm-task-number"><p>Task 3:</p></div>

To get you started, the quest tool has provided you with a system you can use
to try out the agent installation.

Use `ssh` to connect to `hello.puppet.vm`. Your credentials are:

**username: learning**  
**password: puppet**

    ssh learning@hello.puppet.vm

Now that you're connected to this system, copy in the command listed below to
load the agent installer from the master and run it.

(If the script hangs due to an inability to access the required repositories,
it may be due to changing networks or network settings since the agent node was
created. The easiest way to address this is by rebooting the VM and running
`quest begin hello_puppet` to restart this quest and re-create the agent node.)

    sudo curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | bash

Note that if your Agent node is running on a different operating system than
the Master, you will have to take some steps to ensure that the correct
installation script available. In this case, our master and agent are both
running CentOS 7, so we don't have to worry about this difference. You can find
full documentation of the agent installation process, including specific
instructions for Windows and other operating systems on our [docs
page](https://docs.puppet.com/pe/latest/install_agents.html)

## Resources

As we noted above, the Puppet agent comes with a set of supporting tools you
can use to explore your system from a Puppet's-eye-view. Now that the agent is
installed, let's take a moment to explore these tools and see what they can
teach you about how Puppet works.

One of Puppet's core concepts is something called the *resource abstraction
layer*. For Puppet, each aspect of the system you want to manage (users, files,
services, and packages are some of the most common examples) is represented in
Puppet code as a unit called a *resource*.

<div class = "lvm-task-number"><p>Task 4:</p></div>

Be sure you're still connected your agent node, and run the
following command to ask Puppet to describe a file resource:

    puppet resource file /tmp/test

What you see is the Puppet code representation of a resource. In this case,
the resource's type is `file`, and its path is
`/tmp/test":

```puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

Let's break down this resource syntax into its different components so we
can see the anatomy of a resource a little more clearly.

```puppet
type { 'title':
   parameter => 'value',
}
```

The **type** tells Puppet what kind of thing the resource describes.  It can be
a **core type** like a user, file, service, or package, or a **custom type**
that you have implemented yourself or installed from a module. Custom types let
you use describe resources that might be specific to a service or application
(for example, an Apache vhost or MySQL database) that Puppet doesn't know about
out of the box. Internally, a resource's type is what points Puppet to the set
of tools it will use to manage the resource on your system.

The body of a resource is a list of **parameter value pairs** that follow the
pattern `parameter => value`. The parameters and possible values vary from type
to type. These specify the state of the resource on the system. Documentation
for resource parameters is provided in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

The **resource title** is a unique name that Puppet uses to identify the
resource internally. You probably noticed that the title, in the case of our
file resource, is actually the file's path. All resources have a special
parameter that will default to the value of the resource's title.  In the case
of the file resource, this special parameter is the `path`. We could actually
use a different title for the resource as long as we then set the path
explicitly:

```puppet
file { 'my_file':
  ensure => 'absent',
  path   => '/tmp/test',
}
```

Because a file's path parameter must be specify a unique path on the
filesystem, letting it do double-duty as a title will save you time and make
your Puppet code easier to read. All resource types have a similar special
parameter that lets the title do double-duty. This special parameter is called
a **namevar**. You can find more information about the **namevar** for
different resource types in the [Resource Type
Reference](https://docs.puppet.com/puppet/latest/reference/type.html).

This can be a little confusing, so let's reiterate: technically, the *title* is
just a unique identifier that let's Puppet keep track of the resource. For
convenience, however, the title will automatically be used as the default for a
parameter called the namevar. The namevar is the *path* in the case of a file
resource, for example, or the *package* you want to install with a *package*
resource.

Now that you're more familiar with the resource syntax, let's take another look
at that file resource.

``` puppet
file { '/tmp/test':
  ensure => 'absent',
}
```

Notice that it has a single parameter value pair: `ensure => 'absent'`. The
`ensure` parameter tells us the basic state of a resource. For the *file* type,
this parameter will tell us if the file exists on the system and whether it's a
normal file, a directory, or link.

<div class = "lvm-task-number"><p>Task 5:</p></div>

So Puppet is telling us that this file doesn't exist. Let's see what happens
when you use the `touch` command to create a new empty file at that path.

    touch /tmp/test

Now use the `puppet resource` tool to see how this change is represented in
Puppet's resource syntax.

    puppet resource file /tmp/test

Now that the file exists on the system, Puppet has more to say about it. The
resource Puppet shows will include the first two parameter value pairs shown
below as well as some information about the file's owner and when it was
created and last modified.

``` puppet
file { '/tmp/test':
  ensure  => 'file',
  content => '{md5}d41d8cd98f00b204e9800998ecf8427e',
  ...
}
```

When the `puppet resource` tool interprets a file in this resource declaration
syntax, it converts the content to an MD5 hash. This hashing lets Puppet
quickly compare the actual content of a file on your system against the
expected content to see if any change is necessary.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Let's use the `puppet resource` tool to add some content to our file.

Running `puppet resource` with a `parameter=value` argument will tell Puppet to
modify the resource on the system to match the value you set. (Note that while
this is a great way to test out changes in a development environment, it's not
a good way to manage production infrastructure.  Don't worry, though, we'll get
to that soon enough.) We can use this to set the content of your file resource.

    puppet resource file /tmp/test content='Hello Puppet!'

Puppet will display some output as it checks the hash of the existing content
against the new content you provided and modifies the content to match the new
value.

<div class = "lvm-task-number"><p>Task 6:</p></div>

Take another look at the file to see the modified content:

    cat /tmp/test

### Types and Providers

This translation back and forth between the state of the system and Puppet's
resource syntax is the heart of Puppet's **Resource Abstraction Layer**. To get
a better understanding of how this works, let's take a look at another resource
type, the `package`. Since we were playing with an `index.html` file earlier,
let's stay with that theme and have a look at the package resource for the
Nginx server.

    puppet resource package httpd

Again, because this package doesn't exist on the system, Puppet shows you the
`ensure => absent` parameter value pair.

```puppet
package { 'httpd':
  ensure => 'absent',
}
```

As we mentioned above, each resource **type** has a set of **providers**. A
**provider** is the translation layer that sits between Puppet's resource
representation and the native system tools it uses to discover and modify the
underlying system state. Each resource type generally has a variety of
different providers.

These providers can seem invisible when everything is working correctly, but
it's important to understand how they interact with the underlying tools.

As it turns out, the quickest way to see the inner workings of a provider
is to break it. Let's tell Puppet to install a non-existant package named
`bogus-package` and take a look at the error message.

    puppet resource package bogus-package ensure=present

You'll see an error message telling you that yum wasn't able to find the
specified package, including the command that Puppet's yum provider tried to
run when it saw that the package wasn't already installed.

```
Error: Execution of '/bin/yum -d 0 -e 0 -y install bogus-package' returned 1:
Error Nothing to do
```

Puppet selects a default provider based on a node's operating system and
whether the commands associated with that provider are available. You
can override this default by setting a resource's `provider` parameter.

Let's try installing the same fake package again, this time with the pip
provider.

     puppet resource package bogus-package ensure=present provider=pip

You'll see a similar error with a failed pip command instead of the yum
command.

```
Error: Execution of '/bin/pip install -q bogus-package' returned 1: Could not
find a version that satisfies the requirement bogus-package (from versions: )
No matching distribution found for bogus-package
```

Now that you know what's happening in the background, let's try installing
a real package with the default provider.

    puppet resource package httpd ensure=present

This time, Puppet will be able to install the package, and the value of the
`ensure` parameter will show you the specific version of the package installed.

```puppet
package { 'httpd':
  ensure => '2.4.6-45.el7.centos',
}
```

## Review

We covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

Now that you've learned some of the core concepts behind Puppet, you're ready
to use these ideas in a more realistic workflow. As we noted above, the `puppet
resource` command is a great way to explore a system or test Puppet code, but
it's not the tool you'll be using to automate your configuration management.

In the next quest, we'll show you how the Puppet agent communicates with your
Puppet master to fetch a **catalog**, a compiled list of resources, and apply
that catalog to your system.

You'll learn how to save your Puppet code to a file called a **manifest** and
organize it into a **module** within your Puppet master's **codedir**. This
structure lets Puppet keep track of where to find all the resources it needs
to manage your infrastructure.

### Review

## Running the Puppet agent

The `puppet resource` and `facter` commands we explored above show you how
Puppet's resource abstraction layer works on your agent node. This tools are
useful for exploring the state of an unfamiliar system, but by themselves,
don't offer a considerable advantage over native commands or scripting. The
real benefit of Puppet's RAL is as an interface for centralization and
automation.

Let's walk through a Puppet agent run so you can understand how this system
works.

When you installed the Puppet agent, it set up a configuration file that tells
the agent node how to find and connect to the Puppet master. Until the Puppet
master knows to trust the Agent, however, you won't be able to complete a
Puppet agent run. To authenticate your agent node to the Puppet master, you
will have to sign its certificate. This allows SSL communication between the
Puppet master and agent nodes.

<div class = "lvm-task-number"><p>Task 12:</p></div>

Just to see what happens, try to trigger a puppet agent run without your agent
node's certificate signed. The agent will attempt to contact the Puppet master,
but its request will be rejected.

    puppet agent -t

You'll see a notification like the following:

    Exiting; no certificate found and waitforcert is disabled

No problem, you just have to sign the certificate. For now, we'll show you how
to do it from the command line, but if you prefer a GUI, the PE console
includes tools for certificate management.

<div class = "lvm-task-number"><p>Task 13:</p></div>

First, exit your SSH session to return to the your Puppet master node.

    exit

Use the `puppet cert` tool to list the unsigned certificates on your network.

    puppet cert list

Sign the cert for `hello.puppet.vm`.

    puppet cert sign hello.puppet.vm

<div class = "lvm-task-number"><p>Task 14:</p></div>

With that taken care of, the Puppet agent on your node will be able to contact
the Puppet master to get a compiled catalog of all the resources on the system
it needs to manage. By default, the Puppet agent will do this every thirty
minutes to automatically keep your infrastructure in line. Because it would be
difficult to demonstrate much with these scheduled background runs, however,
we have disabled these periodic agent runs. Instead, you will manually trigger
puppet runs so you can observe their effects.

Go ahead and reconnect to your agent node:

    ssh learning@hello.puppet.vm

Trigger another agent run. With your certificate signed, you'll see some
action.

    sudo puppet agent -t

While you haven't told Puppet to manage any resources on the system, you'll see
a lot of text scroll by. This process is called pluginsync. During pluginsync,
your agent checks to ensure that it has all the tools it needs to implement the
RAL and facter, and that the versions of these tools match what's on the
master.

This pluginsync process adds a lot of clutter. Without it, you'd see something
like the following.

```
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Loading facts
Info: Caching catalog for hello.puppet.vm
Info: Applying configuration version '1464919481'
```

Though this output only shows a few of the things the Puppet agent is doing, it
gives you a few clues about the conversation between the agent and master. For
now, we'll focus on two key steps in this conversation.

First, the agent node sends a collection of facts to the Puppet master. These
are the same facts you see when you run the `facter` tool yourself. The Puppet
master takes these facts and uses them with your Puppet code to compile a
catalog. While Puppet code can contain language features such as conditionals
and variables, the catalog is the final parsed list of resources and parameters
that the Puppet master sends back to the agent node to be applied.

![image](../assets/SimpleDataFlow.png)

When you triggered a Puppet run, the Puppet master didn't find any Puppet code
to apply to your agent node, so it didn't make any changes. If we want to see
anything interesting happen, we'll have to tell the master what code we want
applied to our node.

<div class = "lvm-task-number"><p>Task 15:</p></div>

End your SSH session to return to the Puppet master:

    exit

Generally, you will organize all your Puppet code into classes and modules, but
just this once, we're going to make an exception and write some code directly
into the `site.pp` manifest. This manifest is one of the ways the Puppet master
determines what Puppet code should be applied to a node. Open the `site.pp`
manifest for the production environment.

    vim /etc/puppetlabs/code/environments/production/manifests/site.pp

First, we'll create block of code called a node delcaration.

```puppet
node hello.learning.puppetlabs.vm {
}
```

After the Puppet agent sends the facts from a node to the Puppet master, one of
the first step in compiling a catalog is to find a node block that matches the
agent node's fqdn fact. (We'll get into some more elaborate ways you can do
this step—such as using different facts and matching them against regular
expressions—in a later quest.)

With this node declaration in place, you can tell Puppet what resources you
want to manage on that node. For now, we'll use a resource type called `notify`
to output a message that we'll see as the Puppet run occurs and in Puppet's
logs. The notify resource type is a little different than most other resource
types in that it doesn't actually make any changes to the system. It can be
very useful, however, for testing and troubleshooting.

```puppet
node hello.learning.puppetlabs.vm {
  notify { 'Hello Puppet!':
    message => 'Hello Puppet!',
  }
}
```

(Note that while you'll learn the syntax more quickly if you type your code
manually, if you do want to paste content into vim, you can hit `ESC` to enter
command mode and type `:set paste` to disable the automatic formatting. Be sure
to press `i` to return to insert mode before pasting your text.)


Remember, use `ESC` then `:wq` to save and exit.

<div class = "lvm-task-number"><p>Task 16:</p></div>

It's always a good idea to check your code before you run it. 

    puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp

<div class = "lvm-task-number"><p>Task 17:</p></div>

Now SSH to your agent node:

    ssh root@hello.learning.puppetlabs.vm

And trigger another puppet run

    puppet agent -t

The output will include something like this:

    Notice: Hello Puppet!
    Notice: /Stage[main]/Main/Node[hello.learning.puppetlabs.vm]/Notify[Hello Puppet!]/message: defined 'message' as 'Hello Puppet!'
    Notice: Applied catalog in 0.45 seconds

Now that you've seen how to manage user accounts with the RAL and use the
`site.pp` manifest on your master to create node definitions, you're ready to
bring the two concepts together. In the next quest, you'll see how to create
a Puppet module to manage user accounts.

## Review

Nice work, you've finished the first quest on your way to Puppet mastery. At
this point you should have a general understanding of what Puppet is and some
of its core concepts and tools.

We covered the the installation of the Puppet agent on a new node using an
install script hosted on the Puppet master.

With that new node set up, you learned about the *resource abstraction layer*,
a key Puppet concept. You used `facter` to view system facts, and used the
`puppet resource` tool to investigate and modify the state of a `user`
resource.

We introduced the role of certificates in the master/agent relationship, and
the communication that takes place during a puppet agent run. Finally, you
defined a `notify` resource in the master's `site.pp` manifest and triggered
a puppet agent run on the agent node to enforce that configuration.

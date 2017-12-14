{% include '/version.md' %}

# Hiera

## Quest objectives

- Use Hiera to abstract site-specific data from your Puppet manifests.
- Manage the Hiera configuration file.
- Set up YAML data source to use with Hiera.
- Use Hiera lookups in your Puppet manifests.

## Getting started

Hiera is a data lookup system 

When you're ready to get started, type the following command:

    quest begin hiera

## What is Hiera?

All of the methods for managing data you've encountered so far in this guide,
from variables and templates to the roles and profiles pattern, get you closer
to a clean separation of data from code.
[Hiera](https://docs.puppet.com/puppet/latest/hiera_intro.html) is Puppet's
built-in data lookup system. It lets you complete this separation by moving
data out of your Puppet manifests and into a separate data source.

Hiera takes its name from the fact that it allows you to organize your data
*hierarchically*. Most Hiera implementations begin with common data to set
default values across your whole infrastructure and end with node-specific data
needed to configure a unique system. Any data specified on the more specific
level overrides the default set on the more general level. Between these
most-general and most-specific levels, Hiera allows you to specify any number
of intermediate levels.

Though we haven't addressed the topic in this guide, implementing (custom and
external facts)[https://docs.puppet.com/facter/latest/custom_facts.html] gives
you great leeway in setting up your Hiera hierarchies. For example, you might
include a Hiera level corresponding to a country to specify default locale
configuration for a set of workstations or a level corresponding to datacenter
to help manage network configurations.

Like Puppet itself, Hiera is a flexible tool that can be configured and used in
a great variety of ways. The goal of this quest is not to cover the full range
of Hiera's features or possible implementations, but to offer a simple version
of pattern that many Puppet users have used successfully in both large and
small-scale deployments.

Before diving into the implementation, let's take a moment to plan out our
goals for this quest.

When you started this quest, the `quest` tool created four new nodes:

    1. `pasture-app.beauvine.vm`
    2. `pasture-db.auroch.vm`
    3. `pasture-app.auroch.vm`
    4. `pasture-app-dragon.auroch.vm`

In previous quests, you used a conditional statement in your
`profile::pasture::app` class to distinguish between nodes with the words
`large` and `small` in their host names and decide which would be connected to
your database node.

For this quest, we'll make a similar distinction, but handle it a little
differently. Let's imagine that you've set up a tiered pricing structure for
your Cowsay as a Service application. Your basic tier offers only basic cowsay
API features, while your your premium level customers get the added database
features. The hot new startup Beauvine is paying for the basic service, while
their competitor, the more established Auroch has opts for your premium
service. Auroch also insists that you also set up a custom one-off
instance of the application using cowsay's dragon character as the default.

Your goal is too create a Hiera configuration that will provide parameter
values to configure your Pasture application servers at the global, per-domain,
and per-node levels.

<div class = "lvm-task-number"><p>Task 1:</p></div>

The first step in implementing Hiera is to add a `hiera.yaml` configuration
file to your environment's code directory. This configuration file defines the
levels in your hierarchy and tells Hiera where to find the data source that
corresponds to each level.

First, make sure you're working in the production environment's code
directory:

    cd /etc/puppetlabs/code/environments/production

Start work on the `hiera.yaml` file.

    vim hiera.yaml

We'll implement a simple hierarchy with three levels: "Common data" to set up
environment defaults, "Per-Domain defaults" to define domain-specific defaults,
and "Per-node data" to define specific data values for individual nodes.

```yaml
---
version: 5

defaults:
  datadir: data
  data_hash: yaml_data

hierarchy:
  - name: "Per-node data"
    path: "nodes/%{trusted.certname}.yaml"

  - name: "Per-domain data"
    path: "domain/%{facts.networking.domain}.yaml" 

  - name: "Common data"
    path: "common.yaml"
``` 

When Puppet uses Hiera to look for a value, it searches according to the order
of levels listed under this configuration file's `hierarchy:` section. If
a value is found in a data source defined for the "Per-node data" level, that
value is used. If no matching value is found there, Hiera tries the next level:
in this case, "Per-OS defaults". Finally, if no value is found in the previous
data sources, Hiera looks in the "Common data" level's `common.yaml` file.

Because this configuration file is written in
(YAML)[http://www.yaml.org/start.html], not Puppet code you cannot use the
`puppet parser validate` command to check your syntax. Instead use the
following Ruby one-liner from the command line to check your YAML syntax. Keep
in mind that like `puppet parser`, this will only verify that your file can be
parsed, not guarantee that the content is correct.

ruby -e "require 'yaml';require 'pp';pp YAML.load_file('./hiera.yaml')"

Expect to see the following output:

```ruby
{"version"=>5,
 "defaults"=>{"datadir"=>"data", "data_hash"=>"yaml_data"},
 "hierarchy"=>
  [{"name"=>"Per-node data", "path"=>"nodes/%{trusted.certname}.yaml"},
   {"name"=>"Per-domain data",
    "path"=>"domain/%{facts.networking.domain}.yaml"},
   {"name"=>"Common data", "path"=>"common.yaml"}]}
```

Before setting up your data sources for these levels, make some changes to the
`profile::pasture::app` class. By doing this first, you will know which values
you need to define in your data sources.

    vim modules/profile/manifests/pasture/app.pp

Here, use the built-in Hiera `lookup()` function to tell Puppet to fetch data
for each of the `pasture` component class parameters you want to manage.

```puppet
class profile::pasture::app {
  class { 'pasture':
    default_message   => lookup('profile::pasture::app::default_message'),
    sinatra_server    => lookup('profile::pasture::app::sinatra_server'),
    default_character => lookup('profile::pasture::app::default_character'),
    db                => lookup('profile::pasture::app::db'),
  }
}
```

Note that these lookup keys include a fully qualified scope. Though Hiera
itself doesn't require this naming pattern for these keys, this pattern allows
anyone looking at a key in a data source to know exactly how and where it
is used in Puppet code.

(Hiera also has an implicit data binding feature which makes direct use of
fully qualified keys to set class parameters without an explicit lookup.
Because this feature can make the relationship between Puppet code and Hiera
data less clear, however, the `lookup()` function is preferred, especially when
members of your team are less familiar with Hiera.)

Now that you've added lookup functions to your profile, it's time to define
the data in your Hiera data sources.

Hiera is very flexible in the kinds of data sources it can use. The two most
common plain-text formats for Hiera data sources are YAML and JSON, but it can
be configured to use anything (such as a database or even a custom script) that
can take a key as input and return a corresponding value.

Though this flexibility may tempt you to implement a creative solution, it's
best to use the simplest data source that meets your needs. For that reason,
we'll use YAML files for all the data sources in this quest.

Create a `data` directory with `domain` and `nodes` subdirectories.

    mkdir -p data/{domain,nodes}

Begin with your `common.yaml` data source, which is kept directly under the
`data` directory.

    vim data/common.yaml

Here, set common defaults to be used when no value is set in a higher level.

```yaml
---
profile::pasture::app::default_message: "Baa"
profile::pasture::app::sinatra_server: "thin"
profile::pasture::app::default_character: "sheep"
profile::pasture::app::db: "none"
```

Next, create the `data/domain/beauvine.vm.yaml` data source to define defaults
for the `beauvine.vm` domain name. Note that because the domain level is above
the common level in your hierarchy, the values set here take precedence over
those set in common, while the values left undefined default to those set in
common.

    vim data/domain/beauvine.vm.yaml

```yaml
---
profile::pasture::app::default_message: "Welcome to Beauvine!"
```

Next, create the `data/domain/auroch.vm.yaml` data source.

    vim data/domain/auroch.vm.yaml

```yaml
---
profile::pasture::app::default_message: "Welcome to Auroch!"
profile::pasture::app::db: "postgres://pasture:m00m00@pasture-db.auroch.vm/pasture"
```

Now that the data sources for the domain level are complete, move on to the
node level.

    vim data/nodes/pasture-app-dragon.auroch.vm.yaml

Here, just set the `default_character` to `dragon`. 

```yaml
---
profile::pasture::app::default_character: 'dragon'
```

Your data directory should now look like the following:

```
[/etc/puppetlabs/code/environments/production]
root@learning: # tree data
data
├── common.yaml
├── domain
│   ├── auroch.vm.yaml
│   └── beauvine.vm.yaml
└── nodes
    └── pasture-app-dragon.auroch.vm.yaml
```
2 directories, 4 files

Next you will use the `puppet job` tool to trigger a puppet agent run on each
of these nodes.  Remember, the Learning VM is running both your PE master and
the containerized agent nodes themselves, both with a memory allocation below
recommended minimums. This means you need to be a gentle when triggering
concurrent Puppet agent runs. Use the `--concurrency 2` flag to restruct the
number of concurrent agent runs to 2.

    puppet job run --nodes pasture-db.auroch.vm,pasture-app-dragon.auroch.vm,pasture-app.auroch.vm,pasture-app.beauvine.vm --concurrency 2

Now test out some of the API endpoints for these nodes to see what happens.
Before entering each of the following commands, see if you can guess what the
result will be!

    curl pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings

    curl -X POST 'pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings?message=Hello!'

    curl pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings

    curl pasture-app.auroch.vm/api/v1/cowsay/sayings/1

    curl pasture-app.beauvine/api/v1/cowsay

    curl pasture-app.beauvine.vm/api/v1/cowsay/sayings

## Review

In this quest, we introduced defined resource types, a way to bundle a group of
resource declarations into a repeatable and configurable group.

We covered a few key details you should keep in mind when you're working
on a defined resource type:

  * Defined resource type definitions use similar syntax to class declarations,
    but use the `define` keyword instead of `class`.
    to remain unspecified when the defined type is declared.

## Additional Resources

* YAML docs.

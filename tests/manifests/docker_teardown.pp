# All the containers in the format 'name' => 'image'
$containers = {
  'agent'    => 'agent',
  'no-agent' => 'no_agent',
  'hello'    => 'no_agent',
}
$containers.each | $key, $image | {
  docker::run { $key:
    hostname => $key,
    image    => $image,
    ensure   => absent,
  }
}

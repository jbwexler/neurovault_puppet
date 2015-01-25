define neurovault::celery (
    $redis_apt_repo,
)

{

  package { 'software-properties-common':
    ensure => installed,
  } ->

  exec { 'add_redis_repo':
    command => "add-apt-repository $redis_apt_repo",
  } ->

  exec { "update_packages_for_redis":
    command => "apt-get update"
  } ->

  package { 'redis-server':
    ensure => installed,
  }

}



define neurovault::database (
    $env_path,
    $app_path,
    $system_user,
    $db_name,
    $db_username,
    $db_userpassword,
    $db_existing_sql,
)

{

  # config database

 file { "pgpass":
    path => "/home/$system_user/.pgpass",
    content => "localhost:5432:$db_name:$db_username:$db_userpassword",
    ensure  => "present",
    mode => 0600,
    owner => $system_user,
    group => $system_user,
 }

 exec { 'load_existing_db':
    command         => "psql -d $db_name -f $db_existing_sql -U $db_username -h localhost",
    user            => $system_user,
    onlyif          => ["test -f $db_existing_sql",
                        "sh /etc/puppet/modules/neurovault/tests/database_empty.sh $db_name"],
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    require         => File['pgpass'],
 } ->

 notify { 'load_existing':message => "loading existing database from sql dump $db_existing_sql." }

 exec { 'django_migrate_empty_db':
    command         => "$env_path/bin/python $app_path/manage.py migrate",
    user            => $system_user,
    cwd             => $app_path,
    onlyif          => ["test ! -f $db_existing_sql",
                        "sh /etc/puppet/modules/neurovault/tests/database_empty.sh $db_name"],
    path            => ['/usr/bin','/usr/sbin','/bin','/sbin'],
    returns         => [0,1],
  } ->

  notify { 'generate_new':message => "generating new database, no existing sql dump found." }



}

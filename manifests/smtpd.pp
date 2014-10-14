define neurovault::smtpd (
  $host_name,
  $gmail_login_str,
)

{

  if $gmail_login_str != "" {

    Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

    # Clone the xnat builder dev branch, create files and set permissions (step 1)
    exec { "config_postfix_debconf_fqdn":
      command => "debconf-set-selections <<< \"postfix postfix/mailname string $host_name\"",
      returns => [0,2]
    } ->

    exec { "config_postfix_debconf_type":
      command => "debconf-set-selections <<< \"postfix postfix/main_mailer_type string 'Internet Site'\"",
      returns => [0,2]
    } ->

    package { "postfix":
      ensure => "installed"
    } ->

    package { "mailutils":
      ensure => "installed"
    } ->

    package { "libsasl2-2":
      ensure => "installed"
    } ->

    package { "ca-certificates":
      ensure => "installed"
    } ->

    package { "libsasl2-modules":
      ensure => "installed"
    } ->

    file_line { "main_cf1":
      path  => "/etc/postfix/main.cf",
      line  => "relayhost = [smtp.gmail.com]:587",
      match => "^relayhost",
    } ->

    file_line { "main_cf2":
      path  => "/etc/postfix/main.cf",
      line  => "smtp_sasl_auth_enable = yes",
      match => "^smtp_sasl_auth_enable",
    } ->

    file_line { "main_cf3":
      path  => "/etc/postfix/main.cf",
      line  => "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd",
      match => "^smtp_sasl_password_maps",
    } ->

    file_line { "main_cf4":
      path  => "/etc/postfix/main.cf",
      line  => "smtp_sasl_security_options = noanonymous",
      match => "^smtp_sasl_security_options",
    } ->

    file_line { "main_cf5":
      path  => "/etc/postfix/main.cf",
      line  => "smtp_tls_CAfile = /etc/postfix/cacert.pem",
      match => "^smtp_tls_CAfile",
    } ->

    file_line { "main_cf6":
      path  => "/etc/postfix/main.cf",
      line  => "smtp_use_tls = yes",
      match => "^smtp_use_tls",
    } ->

    file { "/etc/postfix/sasl_passwd":
      ensure => present,
      content => "[smtp.gmail.com]:587    $gmail_login_str",
      mode => 400,
    } ->

    exec { "postmap_sasl":
      command => "postmap /etc/postfix/sasl_passwd",
      cwd => "/etc/postfix",
      creates => "/etc/postfix/sasl_passwd.db",
    } ->

    exec { "validate_certs":
      command => "cat /etc/ssl/certs/Thawte_Premium_Server_CA.pem | tee -a /etc/postfix/cacert.pem",
      cwd => "/etc/ssl/certs",
      creates => "/etc/postfix/cacert.pem",
    } ->

    service { postfix :
      ensure => running,
      enable => true,
      hasrestart => true,
      hasstatus => true,
    }

  }

}

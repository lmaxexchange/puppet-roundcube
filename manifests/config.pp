# == Class roundcube::config
#
# This class is called from roundcube
#
class roundcube::config(
  $base_version       = $::roundcube::base_version,
  $conf_dir           = $::roundcube::conf_dir,
  $conf_file          = $::roundcube::conf_file,
  $conf_file_owner    = $::roundcube::conf_file_owner,
  $conf_file_group    = $::roundcube::conf_file_group,
  $conf_file_template = $::roundcube::conf_file_template,
  $main_inc_php_erb   = $::roundcube::main_inc_php_erb,
  $backend            = $::roundcube::backend,
  $database_host      = $::roundcube::database_host,
  $database_port      = $::roundcube::database_port,
  $database_name      = $::roundcube::database_name,
  $database_username  = $::roundcube::database_username,
  $database_password  = $::roundcube::database_password,
) inherits roundcube {

  #LB: selectively determine which template to use using the base_version.
  #RoundCube 1.0 uses config.inc.php, previous versions use main.inc.php.
  $conf_file_template_to_use = $base_version ? {
    '1.0'   => $conf_file_template,
    default => $main_inc_php_erb,
  }

  file { "${conf_dir}/${conf_file}":
    ensure  => present,
    owner   => $conf_file_owner,
    group   => $conf_file_group,
    mode    => '0640',
    content => template($conf_file_template_to_use),
  }

  #LB: these appear to be Debian specific config files, they are not in the
  #CentOS RPM.
  if ($::osfamily == 'debian') {
    file { "${apache::confd_dir}/roundcube.conf":
      ensure => link,
      target => "${roundcube::conf_dir}/apache.conf",
    }

    file { "${apache::confd_dir}/javascript-common.conf":
      ensure => link,
      target => '/etc/javascript-common/javascript-common.conf',
    }
  }

  #LB: logrotate file for RC 1.1.1 is broken and doesn't include all files.
  file { '/etc/logrotate.d/roundcubemail':
    ensure  => present,
    content => template("${module_name}/roundcubemail.logrotate.erb"),
    mode    => '0644',
  }
}

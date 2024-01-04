# @api private
class postgresql::repo::yum_postgresql_org inherits postgresql::repo {
  $version_parts       = split($postgresql::repo::version, '[.]')
  $package_version     = "${version_parts[0]}${version_parts[1]}"
  $gpg_key_path        = "/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${package_version}"
  $gpg_key_path_common = '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-common'

  file { $gpg_key_path:
    content => file('postgresql/RPM-GPG-KEY-PGDG'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Yumrepo['yum.postgresql.org'],
  }

  file { $gpg_key_path_common:
    content => file('postgresql/RPM-GPG-KEY-PGDG-common'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Yumrepo['pgdg-common'],
  }

  if($facts['os']['name'] == 'Fedora') {
    $label1 = 'fedora'
    $label2 = $label1
  } else {
    $label1 = 'redhat'
    $label2 = 'rhel'
  }
  $default_baseurl = "https://download.postgresql.org/pub/repos/yum/${postgresql::repo::version}/${label1}/${label2}-\$releasever-\$basearch"
  $default_commonurl = "https://download.postgresql.org/pub/repos/yum/common/${label1}/${label2}-\$releasever-\$basearch"

  $_baseurl = pick($postgresql::repo::baseurl, $default_baseurl)
  $_commonurl = pick($postgresql::repo::commonurl, $default_commonurl)

  yumrepo { 'yum.postgresql.org':
    descr    => "PostgreSQL ${postgresql::repo::version} \$releasever - \$basearch",
    baseurl  => $_baseurl,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${package_version}",
    proxy    => $postgresql::repo::proxy,
  }

  yumrepo { 'pgdg-common':
    descr    => "PostgreSQL common RPMs \$releasever - \$basearch",
    baseurl  => $_commonurl,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-common',
    proxy    => $postgresql::repo::proxy,
  }

  Yumrepo['yum.postgresql.org'] -> Package<|tag == 'puppetlabs-postgresql'|>
}

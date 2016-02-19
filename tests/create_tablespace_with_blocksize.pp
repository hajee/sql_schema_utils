ora_init_param{'MEMORY/DB_32K_CACHE_SIZE':
  ensure => 'present',
  value  => '8M',
}

ora_init_param{'SPFILE/DB_32K_CACHE_SIZE':
  ensure => 'present',
  value  => '8M',
}

ora_tablespace{test_different_blocksize:
  ensure                   => present,
  datafile                 => 'test_different_blocksize',
  block_size               => '32K',
  size                     => 512M,
  logging                  => "yes",
  autoextend               => "on",
  next                     => 128M,
  max_size                 => 1024M,
  extent_management        => local,
  segment_space_management => auto,
  bigfile                  => 'yes',
  timeout                  => 300,
}
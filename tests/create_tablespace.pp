ora_tablespace{test:
  ensure                   => present,
  datafile                 => 'test',
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
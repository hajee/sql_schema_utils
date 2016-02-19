$db_name = 'test'
$tablespace_name = 'test_temp'
$temp_size = 4096

ora_tablespace {"${tablespace_name}@${db_name}":
  ensure                   => present,
  datafile                 => 'temp',
  size                     => "${temp_size}M",
  contents                 => "temporary",
}

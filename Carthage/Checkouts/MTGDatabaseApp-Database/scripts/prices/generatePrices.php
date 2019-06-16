<?php
  error_reporting(E_ALL);

  $pricesPath = realpath(dirname(__FILE__)) . "/prices.sqlite";
  echo("Prices path is: $pricesPath.\r\n");
  if(!file_exists($pricesPath))
  {
    die('Prices database does not exist.');
  }

  $pricesdb = new SQLite3 ( $pricesPath ) or die('Prices database failed to open.');

  // get all data row by row
  $results = $pricesdb->query('SELECT multiverseId, lowPrice, avgPrice, highPrice, priceVersion FROM MagicCardPrices ORDER BY multiverseId ASC')
    or die('Failed to get prices');

  if(0 == count($results))
  {
    print_r('Failed to get any results');
    exit;
  }

  $found = 0;
  $missing = 0;
  $updated = 0;

  $file_w = fopen('../../MTGDatabase/Resources/prices.bin', 'w+');
  fwrite($file_w, date("Y-m-d"));

  while ($row = $results->fetchArray())
  {
    $lowPrice = $row['lowPrice'];
    $avgPrice = $row['avgPrice'];
    $highPrice = $row['highPrice'];
    $multiverseId = $row['multiverseId'];

    if($highPrice > 65535)
    {
      $highPrice /= 100;
      $multiverseId |= 1 << 31;
    }

    if($avgPrice > 65535)
    {
      $avgPrice /= 100;
      $multiverseId |= 1 << 30;
    }

    if($lowPrice > 65535)
    {
      $lowPrice /= 100;
      $multiverseId |= 1 << 29;
    }

    $bin_str = pack('i', $multiverseId);
    fwrite($file_w, $bin_str);

    $bin_str = pack('v', $lowPrice);
    fwrite($file_w, $bin_str);

    $bin_str = pack('v', $avgPrice);
    fwrite($file_w, $bin_str);

    $bin_str = pack('v', $highPrice);
    fwrite($file_w, $bin_str);
  }

  fclose($file_w);
  echo("Finished.\r\n");
?>

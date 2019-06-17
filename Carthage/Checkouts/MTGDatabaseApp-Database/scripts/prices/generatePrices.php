<?php
  error_reporting(E_ALL);

  if(PHP_INT_SIZE !== 8)
  {
    die("Error - Not running on x64. Generating binary file must be run on x64.\r\n");
  }

  $pricesPath = realpath(dirname(__FILE__)) . "/prices.sqlite";
  echo("Prices path is: $pricesPath.\r\n");
  if(!file_exists($pricesPath))
  {
    die('Prices database does not exist.');
  }

  $pricesdb = new SQLite3 ( $pricesPath ) or die('Prices database failed to open.');

  // get all data row by row
  $query  = 'SELECT multiverseId, lowPrice, avgPrice, highPrice, priceVersion FROM MagicCardPrices ';
//  $query .= ' WHERE multiverseId = 464143';
  $query .= ' ORDER BY multiverseId ASC;';

  $results = $pricesdb->query($query)
    or die('Failed to get prices');

  if(0 == count($results))
  {
    print_r('Failed to get any results');
    exit;
  }

  $found = 0;
  $missing = 0;
  $updated = 0;

  $generatedAt = time();

  $file_w = fopen('../../MTGDatabase/Resources/prices.bin', 'w+');
  fwrite($file_w, pack('Q', $generatedAt));

  $cardCounter = 0;
  while ($row = $results->fetchArray())
  {
    ++$cardCounter;

    $lowPrice = intval(floatval($row['lowPrice']) * 100);
    $avgPrice = intval(floatval($row['avgPrice']) * 100);
    $highPrice = intval(floatval($row['highPrice']) * 100);
    $multiverseId = $row['multiverseId'];

/*
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
*/
    $bin_str = pack('l', $multiverseId);
    fwrite($file_w, $bin_str);

    $bin_str = pack('l', $lowPrice);
    fwrite($file_w, $bin_str);

    $bin_str = pack('l', $avgPrice);
    fwrite($file_w, $bin_str);

    $bin_str = pack('l', $highPrice);
    fwrite($file_w, $bin_str);
  }

  fclose($file_w);

  $file_w = fopen('../../MTGDatabase/Resources/pricesTimestamp.bin', 'w+');
  fwrite($file_w, pack('Q', $generatedAt));
  fclose($file_w);

  echo("Finished. Wrote prices for $cardCounter cards.\r\n");
?>

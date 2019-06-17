<?php
  error_reporting ( E_ALL );
  $time = microtime(true);

  $pricesPath = realpath(dirname(__FILE__)) . "/prices.sqlite";
  echo("Prices path is: $pricesPath.\r\n");
  if(!file_exists($pricesPath))
  {
    die('Prices database does not exist.');
  }

  $pricesdb = new SQLite3 ( $pricesPath ) or die('Prices database failed to open.');



  $mtgPath = realpath(dirname(__FILE__)) . "/../../MTGDatabase/Resources/mtg.sqlite";
  echo("mtgPath is: $mtgPath.\r\n");
  if(!file_exists($mtgPath))
  {
    die('mtgPath database does not exist (' . $mtgPath . '.');
  }

  $mtgdb = new SQLite3 ( $mtgPath ) or die('mtgPath database failed to open.');

  $path = realpath(dirname(__FILE__));
  $path = $path . '/notFound.txt';

  $fpNotFound = fopen ( $path, 'w' );

  if ( !$fpNotFound ) die ( 'Unable to open not found file' );

  // Get a timestamp for today. (without HMS).
  $timestampForDay = strtotime(date("Y-m-d", time()));
  $newPriceVersion = time();

  echo ( "New price version is: $newPriceVersion\r\n" );

  // get all data row by row
  $query = 'SELECT card.multiverseId, card.name as cardName, cardSet.name AS setName FROM card INNER JOIN cardSet ON card.cardSetId = cardSet.cardSetId ';
//  $query .= 'WHERE cardSet.cardSetId IN (209) ';
//  $query .= ' WHERE card.multiverseId = 464143;';

  $query .= 'ORDER BY cardSet.name, card.multiverseId ASC';
  $results = $mtgdb->query($query) or die('mtgdb failed');

  if(0 == count($results))
  {
    print_r('Failed to get any results');
    exit;
  }

  $found = 0;
  $missing = 0;
  $updated = 0;
  $alreadyUpdatedToday = 0;

  while ($row = $results->fetchArray ())
  {
    $set = trim($row['setName']);
//    $price = $row['priceVersion'];
    $multiverseId = $row['multiverseId'];

    $result = getXml ( $set, trim($row['cardName'], '" ') );
    if(!$result || empty($result) || '<products />' == $result)
    {
      fwrite ( $fpNotFound, "Cannot find  [" . $row['setName'] . "] [" . $row['cardName'] . "]\r\n" );
      $missing++;
      continue;
    }

    $existsQuery = "SELECT 1 FROM MagicCardPrices WHERE multiverseId = $multiverseId AND lastUpdated = $timestampForDay";
    $existingResults = $pricesdb->query($existsQuery) or die ('Failed to run select');
    $priceRow = $existingResults->fetchArray ();

    if($priceRow && !empty($priceRow) && 1 == $priceRow[0])
    {
      ++$alreadyUpdatedToday;
      continue;
    }


    $dom_document = new DOMDocument();
    $dom_document->loadXML($result);
    $xpath     = new DOMXPath($dom_document);

    $low = $high = $avg = 0;
    $url = "";
    $nodes = $xpath->query('//price');
    
    if(0 == $nodes->length)
    {
      fwrite ( $fpNotFound, "Cannot find  [" . $row['setName'] . "] [" . $row['cardName'] . "]\r\n" );
      $missing++;
      continue;
    }
    
    $low  = 0;
    $high = 0;
    $sum  = 0;

    foreach ($nodes as $node)
    {
      if(0 == $sum)
      {
        $high = $node->nodeValue;
        $low  = $node->nodeValue;
      }
      if($node->nodeValue > $high)
      {
        $high = $node->nodeValue;
      }
      if($node->nodeValue < $node->nodeValue)
      {
        $low = $node->nodeValue;
      }
     
      $sum += $node->nodeValue;
    }
    
    $avg = $sum / $nodes->length;
    $high *= 10;
    $low  *= 10;
    $avg  *= 10;

    $found++;

    // Get the price information from the database
    $query = "SELECT lowPrice, avgPrice, highPrice FROM MagicCardPrices WHERE multiverseId = $multiverseId";

    $result = $pricesdb->query($query) or die("Query failed: $query.\r\n");
    if(0 == count($result))
    {
      $dblow  = 0;
      $dbhigh = 0;
      $dbavg  = 0;
    } // End of we have results
    else
    {
      $dbrow  = $result->fetchArray();
      $dblow  = $dbrow['lowPrice'];
      $dbhigh = $dbrow['highPrice'];
      $dbavg  = $dbrow['avgPrice'];
    }

    if ( $dblow != $low || $dbavg != $avg || $dbhigh != $high)
    {
      $updated++;
      $query = "INSERT OR REPLACE INTO MagicCardPrices (multiverseId, lowPrice, highPrice, avgPrice, priceVersion, lastUpdated) VALUES($multiverseId, $low, $high, $avg, $newPriceVersion, $timestampForDay);";
      $pricesdb->query($query) or die('Update failed.');
    }
  }

  fclose ( $fpNotFound );

  $pricesdb->Close();

  echo ( "Finished Found: $found Updated: $updated Missed: $missing. Already updated today: $alreadyUpdatedToday.\r\n" );
  echo (microtime(true) - $time) . ' elapsed' . "\r\n";

  function getXml ( $setName, $cardName )
  {
    // Have to update our set names for TCGPlayer.com
    if ( $setName == 'Limited Edition Alpha' ) $setName = 'Alpha Edition';
    else if ( 'Limited Edition Beta' == $setName ) $setName = 'Beta Edition';
    else if ( 'Portal Three Kingdoms' == $setName ) $setName = 'Portal';
    else if ( 'Seventh Edition' == $setName ) $setName = '7th Edition';
    else if ( 'Eighth Edition' == $setName ) $setName = '8th Edition';
    else if ( 'Ninth Edition' == $setName ) $setName = '9th Edition';
    else if ( 'Tenth Edition' == $setName ) $setName = '10th Edition';
    else if ( 'Magic 2010' == $setName ) $setName = 'Magic 2010 (M10)';
    else if ( 'Magic 2011' == $setName ) $setName = 'Magic 2011 (M11)';
    else if ( 'Magic 2012' == $setName ) $setName = 'Magic 2012 (M12)';
    else if ( 'Magic 2013' == $setName ) $setName = 'Magic 2013 (M13)';
    else if ( 'Magic 2014 Core Set' == $setName ) $setName = 'Magic 2014 (M14)';
    else if ( 'Magic 2015 Core Set' == $setName ) $setName = 'Magic 2015 (M15)';
    else if ( 'Magic 2016 Core Set' == $setName ) $setName = 'Magic 2016 (M15)';
    else if ( 'Magic 2017 Core Set' == $setName ) $setName = 'Magic 2017 (M15)';
    else if ( 'Magic 2017 Core Set' == $setName ) $setName = 'Magic 2017 (M15)';
    else if ( 'Planechase 2012 Edition' == $setName ) $setName = 'Planechase 2012';
    else if ( 'Magic: The Gathering-Commander' == $setName ) $setName = 'Commander';
    else if ( 'Duel Decks: Knights vs. Dragons' == $setName ) $setName = 'Knights vs Dragons';
    else if ( 'Ravnica: City of Guilds' == $setName ) $setName = 'Ravnica';
    else if ( 'Modern Masters 2015 Edition' == $setName ) $setName = 'Modern Masters 2015';
    else if ( 'Modern Masters 2017 Edition' == $setName ) $setName = 'Modern Masters 2017';

    else if ( 'Commander 2013 Edition' == $setName ) $setName = 'Commander 2013';

//    $target = 'http://partner.tcgplayer.com/x3/phl.asmx/p?pk=HNKNSFT&s=' . urlencode ( $setName ) . '&p=' . urlencode ( $cardName );
    $setName = str_replace("Duel Decks Anthology,", "Duel Decks:", $setName);

    $target = 'http://partner.tcgplayer.com/x3/pv.asmx/p?&v=1000&pk=HNKNSFT&s=' . urlencode ( $setName ) . '&p=' . urlencode ( $cardName );

    for ( $i = 0; $i < 5; ++$i )
    {
      $html = @file_get_contents ( $target );
      if ( false !== $html )
      {
        break;
      }
    }
    
    if ( false === $html || empty($html))
    {
      echo ( "Unable to get results for $target\r\n" );
      return;
    }
    
    if(false !== stripos($html, "Product not found."))
    {
      echo("Empty results for $target.\r\n");
      return;
    }
    
    if(80 == strlen($html))
    {
      echo("Empty results for $target.\r\n");
      return;
    }

    return $html;
  } // End of getXml
?>

<?php
  ini_set('display_errors', 1);
  error_reporting(E_ALL);
  ini_set('memory_limit', '-1');
  set_time_limit(0);

  $root = dirname(__FILE__);

  require_once "./libs/php-zip/zip.php";
  require_once "./classes.php";

  // Delete existing temp directory
  $tempPath = "$root/temp";
  @rrmdir($tempPath);
  @mkdir($tempPath);

  $zipPath = "$tempPath/AllPrintings.json.zip";
  
  // Get our abilities
  $abilities = getAbilities();

  $contents = file_get_contents('https://www.mtgjson.com/files/AllPrintings.json.zip') or die('Failed to download all.');
  file_put_contents($zipPath, $contents) or die('Failed to store file'); 

  // Unzip
  $zip = new Zip();
  $zip->unzip_file($zipPath);
  $zip->unzip_to($tempPath);

  // Get our json object
  $checksum = md5_file("$tempPath/AllPrintings.json");
  $jsonString = file_get_contents("$tempPath/AllPrintings.json") or die('Failed to open json file.');
  $allSets    = json_decode($jsonString);
  unset($jsonString); // Clear memory

  $cardSets = array();
  foreach($allSets as $key=>$val)
  {
    $cardSet = processSet($val);
    if(empty($cardSet))
    {
	    continue;
    }

    array_push($cardSets, $cardSet);
  }

  // Create db
  $database = new SQLite3 ("$tempPath/mtg.sqlite") or die('Prices database failed to open.');

  // Run the initial script
  $initialScript = file_get_contents("$root/Schema.sql");
  $queries = explode(";", $initialScript);
  
  foreach($queries as $query)
  {
	  $query = trim($query);
	  $database->query($query) or die('Initial script failed');
  }

  echo("Writing formats.\r\n");

  $formats = array();
  foreach($cardSets as $cardSet)
  {
    if(empty($cardSet->cards))
    {
	    continue;
    }

    foreach($cardSet->cards as $card)
    {
	    foreach($card->formats as $format)
	    {
		    if(!array_key_exists($format, $formats))
		    {
			    $formats[$format] = 0;
			    continue;
		    }

		    $count = $formats[$format];
		    ++$count;
		    $formats[$format] = $count;
	    }
	}
  }

  // Sort
  ksort($formats, SORT_STRING | SORT_FLAG_CASE);

  // Insert our formats
  foreach($formats as $format => $count)
  {
	  $format = SQLite3::escapeString($format);
	  $query = "INSERT INTO FORMAT (name, cardCount) VALUES('$format', $count);";
	  $database->query($query) or die('Failed to insert format');
  } // End of foreach enumeration

  // Order sets by release date
  usort($cardSets, 'sort_cardset_by_releaseDate');

  $artistLookup = array();
  foreach($cardSets as $cardSet)
  {
      $blankMultiverseIdCount = 0;
	  foreach($cardSet->cards as $card)
      {
         if(!empty($card->artist))
         {
	         array_push($artistLookup, $card->artist);
         }
      } // End of cards enumeration
  }

  $artistLookup = array_unique($artistLookup);
  
  usort($artistLookup, 'strnatcasecmp');

  foreach($artistLookup as $index => $artist)
  {
	  $artistName = SQLite3::escapeString($artist);

	  $query = "INSERT INTO artist (artistId, name) values ($index, '$artistName');";
	  $database->query($query) or die('Failed to insert artist.');
  }

  echo("Writing cardSets\r\n");
  foreach($cardSets as $index => $cardSet)
  {
	  $cardSet->internalSetId = $index;

	  $query = sprintf("INSERT INTO cardSet (cardSetId, name, shortName, cardCount, block, type, releaseDate) values (%d, '%s', '%s', %ld, '%s', '%s', %ld);",
		  $cardSet->internalSetId, SQLite3::escapeString($cardSet->name), SQLite3::escapeString($cardSet->shortName),
		  sizeof($cardSet->cards), SQLite3::escapeString($cardSet->type), SQLite3::escapeString($cardSet->block),
		  $cardSet->releaseDate);

	  $database->query($query) or die('Failed to insert cardSet');
  }

  echo("Writing abilities");
print_r($abilities);

  // Insert abilities
  foreach($abilities as $ability)
  {
    $abilityCounter = 0;

    foreach($cardSets as $cardSet)
    {
	   foreach($cardSet->cards as $card)
	   {
          if(empty($card->cardText))
          {
	         continue;
          }

          if(false === stripos($card->cardText, $ability))
          {
	          continue;
          }

          ++$abilityCounter;
	   } // End of cards enumeration
    } // End of cardSets enumeration

	if(0 == $abilityCounter)
	{
	  echo("Skip ability: $ability\r\n");
	  continue;
	} // End of no abilities

	$escapedAbility = SQLite3::escapeString($ability);
	$query = "INSERT INTO ability(name, cardCount) VALUES('$escapedAbility', $abilityCounter);";
	$database->query($query) or die('Failed to insert abilities');
  } // End of abilities

  echo("Writing cards\r\n");

  $errorCount = 0;
  $successCount = 0;
  $formatKeys = array_keys($formats);

  foreach($cardSets as $cardSet)
  {
      $blankMultiverseIdCount = 0;
	  foreach($cardSet->cards as $card)
      {
          if(empty($card->multiverseId))
          {
              ++$blankMultiverseIdCount;
          }
      }

      if($blankMultiverseIdCount > 1)
      {
          echo(sprintf("Skipping set: (%s) %s", $cardSet.shortName, $cardSet.name));
          continue;
      } // End of cardSet does not have a multiverseId

	  foreach($cardSet->cards as $card)
      {
	      $artistId = array_search($card->artist, $artistLookup, false);
	      if(false === $artistId)
	      {
		      $artistId = -1;
	      }

	      $multiverseId = $card->multiverseId;
	      $internalSetId = $card->set->internalSetId;
	      $cardId = intval($card->cardId);
	      $rarity = SQLite3::escapeString($card->rarity);
	      $cardName = SQLite3::escapeString($card->name);
	      $power = $card->power ?: 0;
	      $color = SQLite3::escapeString($card->color);
	      $toughness = $card->toughness ?: 0;
	      $type = SQLite3::escapeString($card->type);
	      $text = SQLite3::escapeString($card->cardText);
		  $flavorText = SQLite3::escapeString($card->flavorText);
		  $manaCost = SQLite3::escapeString($card->manaCost);
		  $convertedManaCost = SQLite3::escapeString($card->convertedManaCost);

	      $query = sprintf("INSERT INTO card (multiverseId, cardSetId, name, rarity, artistId, color, text, flavorText, cost, convertedManaCost, collectorsNumber, power, toughness, type) values ($multiverseId, $internalSetId, '$cardName', '$rarity', $artistId, '$color', '$text', '$flavorText', '$manaCost', '$convertedManaCost', $cardId, '$power', '$toughness', '$type')");

		  $result = $database->query($query);
		  if(empty($result))
          {
                ++$errorCount;
				echo("$query\r\n");
                echo(sprintf("Failed to update: %ld (%s), %s [%s]",
                      $card->multiverseId,
                      $card->cardId,
                      $card->name,
                      'error'));
                      exit;
            } // End of failed to update
            else
            {
                ++$successCount;
            }

            foreach($card->formats as $format)
            {
                $formatId = array_search($format, $formatKeys, false);
                if(false === $formatId)
                {
  	                echo("Missing format '$format'\r\n");
	                print_r($formatKeys);
					continue;
                }

                $query = "INSERT INTO card_format (multiverseId, formatId) values ($multiverseId, $formatId);";

				@$database->query($query); // or die('Failed to insert card_foramt'); Ignore duplicates
            }
        }
  }

  // Update version using our checksum
  $database->query("UPDATE settings SET value = '$checksum' WHERE name = 'databaseVersion';") or die('Failed to update version.');

echo("Done. Inserted $successCount. Failed: $errorCount\r\n");
exit;



  function getAbilities()
  {
	  $html = file_get_contents("https://en.wikipedia.org/wiki/List_of_Magic:_The_Gathering_keywords") or die('Failed to get keywords');
      $xml = new SimpleXMLElement($html);
      $nodes = $xml->xpath("//ul/li/ul/li/a/span[@class='toctext']");

      $abilities = array();
	  foreach($nodes as $node)
	  {
		  array_push($abilities, trim($node->__toString()));
	  } // End of nodes enumeration
	  
      $abilities = array_unique($abilities);
      usort($abilities, 'strnatcasecmp');
	  return $abilities;
  }






  function processSet($setDictionary)
  {
    $cardSet = new CardSet();
    
    $cardSet->name = $setDictionary->name;
    
    $cardSet->type = $setDictionary->type;
    if(!empty($setDictionary->block))
    {
	    $cardSet->block = $setDictionary->block;
	}

    $cardSet->shortName = $setDictionary->code; // oldcode?

	$dateString = $setDictionary->releaseDate;
    if (empty($dateString))
    {
        // need to have a default date
        $dateString = "1993-01-01";
    }

    $cardSet->releaseDate = strtotime($dateString);

	$setCards = array();
	foreach ($setDictionary->cards as $cardDictionary)
    {
		$card = processCardDictionary($cardDictionary, $cardSet);
        if(!empty($card))
        {
	        array_push($setCards, $card);
        }
    } // End of $cards enumeration

    // Set our $cards
    $cardSet->cards = $setCards;

    // Some sets such as friday night magic, contain no $cards with multiverseIds.
    // We do not handle these sets and ignore them.
    if(0 == sizeof($cardSet->cards))
    {
        return null;
    } // End of we processed no $cards

    return $cardSet;
  } // End of processSet

  function processCardDictionary($cardDictionary, $cardSet)
  {
  	$card = new Card();
    $card->set = $cardSet;

    if(!array_key_exists("multiverseId", $cardDictionary))
    {
        return null;
    }
    else
    {
        $card->multiverseId = $cardDictionary->multiverseId;
    }

    $card->name = $cardDictionary->name;
    if(!empty($cardDictionary->mciNumber))
    {
	    $card->cardId = $cardDictionary->mciNumber;
	}

    if(empty($card->cardId))
    {
        $card->cardId = $cardDictionary->number;
    }

	if(!empty($cardDictionary->artist))
	{
	    $card->artist = $cardDictionary->artist;
	}

	if(!empty($cardDictionary->rarity))
	{
	    $card->rarity = $cardDictionary->rarity;
	}
    
    if(!empty($cardDictionary->manaCost))
    {
	    $card->manaCost = $cardDictionary->manaCost;
	}

    $card->convertedManaCost = $cardDictionary->convertedManaCost;
    
    
    $card->type = $cardDictionary->type;

    // Skip schemas
    if(!strcasecmp($card->type, "Scheme"))
    {
        return null;
    } // End of schema

    if(isset($cardDictionary->power))
    {
	    $card->power = $cardDictionary->power;
	}

	if(isset($cardDictionary->toughness))
	{
	    $card->toughness = $cardDictionary->toughness;
	}

	if(!empty($cardDictionary->flavorText))
	{
	    $card->flavorText = $cardDictionary->flavorText;
	}

	if(!empty($cardDictionary->text))
	{
	    $card->cardText = $cardDictionary->text;
	}

	$colors = $cardDictionary->colors;

    if(sizeof($colors))
    {
		$colorsMapping = array();
		foreach ($colors as $key)
        {
			$colorShortCode = $key;

            if(!strcasecmp($colorShortCode, "B"))
            {
               array_push($colorsMapping, "Black");
            }
            else if(!strcasecmp($colorShortCode, "U"))
            {
                array_push($colorsMapping, "Blue");
            }
            else if(!strcasecmp($colorShortCode, "R"))
            {
                array_push($colorsMapping, "Red");
            }
            else if(!strcasecmp($colorShortCode, "G"))
            {
                array_push($colorsMapping, "Green");
            }
            else if(!strcasecmp($colorShortCode, "W"))
            {
                array_push($colorsMapping, "White");
            }
            else
            {
                array_push($colorsMapping, "UnColored");
            }
        }

        $card->color = implode(",", $colorsMapping);
    }

	$formats = $cardDictionary->legalities;
	$formats = json_decode(json_encode($formats), true);

    if(empty($formats) || 0 == count($formats))
    {
        $card->formats = array("Unplayable");
    }
    else
    {
        $cardFormats = array();
     
  		foreach ($formats as $format => $legality)
        {
            // Skip classic
            if(!strcasecmp($format, "Classic"))
            {
                continue;
            } // End of classis
            else if(!strcasecmp($legality, "Legal"))
            {
                array_push($cardFormats, trim($format));
            }
            else if(!strcasecmp($legality, "Banned"))
            {
            }
            else if(!strcasecmp($legality, "Restricted"))
            {
            }
            else
            {
                echo("????");
            }

        }
        
        $card->formats = $cardFormats;
    }

    return $card;
  }

function rrmdir($dir) { 
   if (is_dir($dir)) { 
     $objects = scandir($dir); 
     foreach ($objects as $object) { 
       if ($object != "." && $object != "..") { 
         if (is_dir($dir."/".$object) && !is_link($dir."/".$object))
           @rrmdir($dir."/".$object);
         else
           @unlink($dir."/".$object); 
       } 
     }
     @rmdir($dir); 
   } 
 }
?>

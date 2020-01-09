<?php
class CardSet {
	public $name;
	public $cards;
	public $shortName;
	public $block;
	public $type;
	public $releaseDate;
	
	public $internalSetId;
};

class Card {

	public $multiverseId;
	public $cardId;
	public $name;
	public $set;
	public $artist;
	public $color;

	public $manaCost;
	public $convertedManaCost;

	public $cardText;
	public $flavorText;
	public $rarity;
	public $type;

	public $power;
	public $toughness;

	public $formats;
};

function sort_cardset_by_releaseDate($a, $b) {
	if($a->releaseDate == $b->releaseDate){ return 0 ; }
	return ($a->releaseDate < $b->releaseDate) ? -1 : 1;
}

?>

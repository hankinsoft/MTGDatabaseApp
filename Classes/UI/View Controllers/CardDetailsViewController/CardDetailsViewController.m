    //
//  CardViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CardDetailsViewController.h"
#import "MTGCard.h"
#import "MTGCardSet.h"
#import "AppDelegate.h"
#import "CardLinksViewController.h"
#import "MTGCardImageTableViewCell.h"
#import "GGFullscreenImageViewController.h"
#import "UITableViewCell+SQLProApperance.h"
#import "MTGCardInDeck.h"
#import "MTGArtist.h"
#import "MTGCardDetailsTableViewCell.h"
#import "MTGCardPriceTableViewCell.h"
#import "Deck.h"
#import "EditDeckViewController.h"
#import "MTGCardImageHelper.h"

#define kSectionImage       0
#define kSectionDescription 1
#define kSectionDetails     2
#define kSectionPricing     3
#define kSectionFlavourText 4
#define kSectionCollections 5
#define kNumberOfSections   6

@interface MTGCardPriceDetails : NSObject

- (id) initWithSupplier: (NSString*) supplierName
              condition: (NSString*) condition
                  price: (NSString*) price
               quantity: (NSString*) quantity
                   link: (NSString*) link;

@property(nonatomic,copy) NSString * supplierName;
@property(nonatomic,copy) NSString * condition;
@property(nonatomic,copy) NSString * price;
@property(nonatomic,copy) NSString * quantity;
@property(nonatomic,copy) NSString * link;

@end

@implementation MTGCardPriceDetails

- (id) initWithSupplier: (NSString*) supplierName
              condition: (NSString*) condition
                  price: (NSString*) price
               quantity: (NSString*) quantity
                   link: (NSString*) link
{
    self = [super init];
    if(self)
    {
        _supplierName = supplierName;
        _condition = condition;
        _price = price;
        _quantity = quantity;
        _link = link;
    }

    return self;
} // End of init

@end

@interface CardDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,DeckCardModifierCellDelegate>
{
    UITableView         * detailsTableView;
    UIBarButtonItem     * linksBarButtonItem;
    UIBarButtonItem     * shareBarButtonItem;
}

@end

@implementation CardDetailsViewController
{
    NSArray<MTGCardPriceDetails*>*      priceDetails;

    NSArray                             * detailKeys;
    NSDictionary                        * detailsDictionary;
    NSIndexPath                         * lastSelectedIndexPath;
    
    UIImage                             * cardImage;
}

@synthesize card;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id) init
{
    self = [super initWithNibName: @"CardDetailsViewController" bundle: nil];

    if(self)
    {
    }

    return self;
} // End of init

- (void) viewDidLoad
{
	[super viewDidLoad];

    linksBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"Card-Links"]
                                                          style: UIBarButtonItemStylePlain
                                                         target: self
                                                         action: @selector(onLinks:)];

    shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"Card-Share"]
                                                          style: UIBarButtonItemStylePlain
                                                         target: self
                                                         action: @selector(onShare:)];

    UIBarButtonItem * closeBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle: @"Close"
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(onClose:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButtonItem;
    self.navigationItem.rightBarButtonItems = @[shareBarButtonItem, linksBarButtonItem];

    [self setup];
    
    NSMutableArray * _detailKeys = @[].mutableCopy;
    NSMutableDictionary * _detailLookup = @{}.mutableCopy;

    [_detailKeys addObject: @"Name"];
    _detailLookup[@"Name"] = card.name;

    [_detailKeys addObject: @"Set"];
    _detailLookup[@"Set"] = [MTGCardSet cardSetById: card.cardSetId].name;

    if(0 != card.cost.length)
    {
        [_detailKeys addObject: @"Casting cost"];
        _detailLookup[@"Casting cost"] = [card castingCostAttributedString];

        [_detailKeys addObject: @"Converted cost"];
        _detailLookup[@"Converted cost"] = [NSString stringWithFormat: @"%ld", (long) card.convertedManaCost];
    } // End of we have a casting cost

    [_detailKeys addObject: @"Type"];
    _detailLookup[@"Type"] = card.type;

    [_detailKeys addObject: @"Artist"];
    _detailLookup[@"Artist"] = [MTGArtist artistById: card.artistId].name;

    [_detailKeys addObject: @"Rarity"];
    _detailLookup[@"Rarity"] = card.rarity;

    [_detailKeys addObject: @"Multiverse id"];
    _detailLookup[@"Multiverse id"] = [NSString stringWithFormat: @"%ld", (long) card.multiverseId];

    if(card.collectorsNumber)
    {
        [_detailKeys addObject: @"Collectors id"];
        _detailLookup[@"Collectors id"] = [NSString stringWithFormat: @"%@", card.collectorsNumber];
    } // End of we have a collectorsNumber

    detailKeys = _detailKeys;
    detailsDictionary = _detailLookup;
    
    // Load our prices in a seperate thread
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray * _priceDetails = [self loadPriceDetails];

        dispatch_async(dispatch_get_main_queue(), ^{
            self->priceDetails = _priceDetails;
            [self->detailsTableView reloadData];
        });
    });
}

- (void) setup
{
    detailsTableView = [[UITableView alloc] initWithFrame: CGRectZero
                                                    style: UITableViewStyleGrouped];
    detailsTableView.separatorColor = [UIColor clearColor];
    detailsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    detailsTableView.tableHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 0, 1)];
    [self.view addSubview: detailsTableView];
    [detailsTableView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [detailsTableView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [detailsTableView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
    [detailsTableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
    detailsTableView.dataSource = self;
    detailsTableView.delegate = self;
}

- (void) copyDetailsCell: (id) sender
{
    // Get our stats
    NSString * stat = detailKeys[lastSelectedIndexPath.row];
    NSString * detail = detailsDictionary[stat];

    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    if([detail isKindOfClass: [NSAttributedString class]])
    {
        NSAttributedString * attributedString = (id) detail;

        NSData *rtf = [attributedString dataFromRange:NSMakeRange(0, attributedString.length)
                                   documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType}
                                                error:nil];

        pasteboard.items = @[@{(id)kUTTypeRTF: [[NSString alloc] initWithData: rtf
                                                                     encoding: NSUTF8StringEncoding],
                               (id)kUTTypeUTF8PlainText: attributedString.string}];
    }
    else
    {
        pasteboard.string = detail;
    }
} // End of copyDetailsCell:

- (NSArray*) loadPriceDetails
{
    NSString * cardSetName = [MTGCardSet cardSetById: card.cardSetId].name;

    // Have to update our set names for TCGPlayer.com
    const NSDictionary * setNameReplacementDictionary =
    @{
      @"Limited Edition Alpha":@"Alpha Edition",
      @"Limited Edition Beta":@"Beta Edition",
      @"Portal Three Kingdoms":@"Portal",
      @"Seventh Edition":@"7th Edition",
      @"Eighth Edition":@"8th Edition",
      @"Ninth Edition":@"9th Edition",
      @"Tenth Edition":@"10th Edition",
      @"Magic 2010":@"Magic 2010 (M10)",
      @"Magic 2011":@"Magic 2011 (M11)",
      @"Magic 2012":@"Magic 2012 (M12)",
      @"Magic 2013":@"Magic 2013 (M13)",
      @"Magic 2014 Core Set":@"Magic 2014 (M14)",
      @"Magic 2015 Core Set":@"Magic 2015 (M15)",
      @"Magic 2016 Core Set":@"Magic 2016 (M15)",
      @"Magic 2017 Core Set":@"Magic 2017 (M15)",
      @"Planechase 2012 Edition":@"Planechase 2012",
      @"Magic: The Gathering-Commander":@"Commander",
      @"Duel Decks: Knights vs. Dragons":@"Knights vs Dragons",
      @"Ravnica: City of Guilds":@"Ravnica",
      @"Modern Masters 2015 Edition":@"Modern Masters 2015",
      @"Modern Masters 2017 Edition":@"Modern Masters 2017",
    };
    
    for(NSString * key in setNameReplacementDictionary.allKeys)
    {
        if(NSOrderedSame == [key caseInsensitiveCompare: cardSetName])
        {
            cardSetName = setNameReplacementDictionary[key];
            break;
        } // End of found a match
    } // End of replace enumeratioh

    NSString * urlEncodedSetName = cardSetName;
    urlEncodedSetName = [urlEncodedSetName stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLHostAllowedCharacterSet]];

    NSString * urlEncodedCardName = card.name;
    urlEncodedCardName = [urlEncodedCardName stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLHostAllowedCharacterSet]];

    NSURL * priceURL = [NSURL URLWithString:
        [NSString stringWithFormat: @"http://partner.tcgplayer.com/x3/pv.asmx/p?&v=1000&pk=HNKNSFT&s=%@&p=%@",
         urlEncodedSetName, urlEncodedCardName]];

    NSURLRequest *request = [NSURLRequest requestWithURL: priceURL];

    NSError * error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest: request
                                         returningResponse: nil
                                                     error: &error];

    if(error)
    {
        return @[];
    }

    GDataXMLDocument * document = [[GDataXMLDocument alloc] initWithData: data
                                                                 options: 0
                                                                   error: &error];

    if(error)
    {
        return @[];
    }
    
    NSMutableArray<MTGCardPriceDetails*>* _priceDetails = @[].mutableCopy;

    NSArray * supplierElements = [document.rootElement elementsForName: @"supplier"];
    for(GDataXMLElement * supplierNode in supplierElements)
    {
        if(0 == [supplierNode elementsForName: @"name"].count ||
           0 == [supplierNode elementsForName: @"condition"].count ||
           0 == [supplierNode elementsForName: @"price"].count ||
           0 == [supplierNode elementsForName: @"qty"].count ||
           0 == [supplierNode elementsForName: @"link"].count)
        {
            continue;
        }

        NSString * supplier = ((GDataXMLElement*)[supplierNode elementsForName: @"name"].firstObject).stringValue;
        NSString * condition = ((GDataXMLElement*)[supplierNode elementsForName: @"condition"].firstObject).stringValue;
        NSString * price = ((GDataXMLElement*)[supplierNode elementsForName: @"price"].firstObject).stringValue;
        NSString * quantity = ((GDataXMLElement*)[supplierNode elementsForName: @"qty"].firstObject).stringValue;
        NSString * link = ((GDataXMLElement*)[supplierNode elementsForName: @"link"].firstObject).stringValue;
        
        if(nil == price || 0 == price.length)
        {
            continue;
        } // End of no price

        MTGCardPriceDetails * priceDetails = [[MTGCardPriceDetails alloc] initWithSupplier: supplier
                                                                                 condition: condition
                                                                                     price: price
                                                                                  quantity: quantity
                                                                                      link: link];

        [_priceDetails addObject: priceDetails];
    }

    [_priceDetails sortUsingComparator: ^NSComparisonResult(MTGCardPriceDetails * _Nonnull obj1, MTGCardPriceDetails * _Nonnull obj2) {
        return [obj1.price compare: obj2.price
                           options: NSNumericSearch];
    }];

    // Reverse -- highest prices first.
    [_priceDetails reverse];

    return _priceDetails;
} // End of beginLoadingPrices

- (void) configureRevealBlock:(RevealBlock)revealBlock
{
    _revealBlock = [revealBlock copy];
    self.navigationItem.leftBarButtonItem = [GHRootViewController generateMenuBarButtonItem: self
                                                                                   selector: @selector(revealSidebar)];
}

- (void) revealSidebar
{
	_revealBlock();
}

- (void) onClose: (id) sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated: YES
                                                                           completion: nil];
} // End of onClose:

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    NSString * powerToughness = @"";
    if(card.power && card.toughness)
    {
        powerToughness = [NSString stringWithFormat: @"%@/%@",
                          card.power,
                          card.toughness];
    }

    // Set our title to the name of the card
    [self setTitle: card.name];

    // Things may have changed (decks mainly), so reload.
    [detailsTableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];

    if(nil != popoverController)
    {
        [popoverController dismissPopoverAnimated: YES];
    }
} // End of viewWillDisappear

- (IBAction) onLinks: (id)sender
{
    CardLinksViewController * cardLinksViewController =
        [[CardLinksViewController alloc] initWithNibName: @"CardLinksViewController"
                                                  bundle: nil];

    cardLinksViewController.card = self.card;
    [self.navigationController pushViewController: cardLinksViewController animated:YES];
} // End of onLinks

- (IBAction) onShare: (id) sender
{
    UIImage * targetCardImage = cardImage;
    if(nil == targetCardImage)
    {
        targetCardImage = [UIImage imageNamed: @"BackOfMagicCard"];
    }
    
    NSURL * shareURL = [NSURL URLWithString: @"https://itunes.apple.com/app/magic-card-database-mtg/id393764621?mt=8"];

    NSArray * dataToShare = @[targetCardImage, shareURL];
    UIActivityViewController * activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems: dataToShare
                                          applicationActivities: nil];

    if(activityViewController.popoverPresentationController)
    {
        activityViewController.popoverPresentationController.barButtonItem = shareBarButtonItem;
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    } // End of we have a popoverPresentationController

    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController: activityViewController
                       animated: YES
                     completion: nil];
    
    weakify(self);
    [activityViewController setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        strongify(self);

        if(activityError)
        {
            return;
        }

        [[HSLogHelper sharedInstance] logEvent: @"Share-Card"
                                   withDetails: @{@"Name": self->card.name,
                                                  @"MultiverseId": @(self->card.multiverseId),
                                                  @"ActivityType": activityType ? activityType : @"<null>"}];
    }];
} // End of onShare:

#pragma mark -
#pragma mark UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
} // End of numberOfSectionsInTableView

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(kSectionDetails == section)
    {
        return @"Details";
    }
    else if(kSectionDescription == section)
    {
        return @"Card text";
    }
    else if(kSectionPricing == section)
    {
        return @"Prices";
    }
    else if(kSectionFlavourText == section)
    {
        return @"Flavor text";
    }
    else if(kSectionCollections == section)
    {
        return @"Collections";
    }
    
    return nil;
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    if(kSectionDetails == section)
    {
        return detailKeys.count;
    }
    if(kSectionDescription == section)
    {
        return 1;
    }
    else if(kSectionImage == section)
    {
        return 1;
    }
    else if(kSectionCollections == section)
    {
        return [Deck decks].count + 1;
    }
    else if(kSectionPricing == section)
    {
        // Pricing details not loaded yet. Dispaly loading cell.
        if(nil == priceDetails)
        {
            return 1;
        }

        // No prices available. Display a cell saying so.
        if(0 == priceDetails.count)
        {
            return 1;
        }

        return priceDetails.count;
    }

    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;

    if(kSectionDetails == indexPath.section)
    {
        static NSString * sectionTableViewCellIdentifier = @"ItemSectionCell";
        cell = [tableView dequeueReusableCellWithIdentifier: sectionTableViewCellIdentifier];
        if(nil == cell)
        {
            cell = [[MTGCardDetailsTableViewCell alloc] initWithStyle: UITableViewCellStyleValue2
                                                      reuseIdentifier: sectionTableViewCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.lineBreakMode = NSLineBreakByClipping;
        }

        cell.detailTextLabel.textColor = [UIColor whiteColor];

        // Get our stats
        NSString * stat = detailKeys[indexPath.row];
        NSString * detail = detailsDictionary[stat];

        // Setup our result
        cell.textLabel.text = stat;
        cell.lightTextColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.250];
        cell.darkTextColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.250];

        if([detail isKindOfClass: [NSAttributedString class]])
        {
            cell.detailTextLabel.attributedText = (id) detail;
        }
        else
        {
            cell.detailTextLabel.text = detail;
        }

        return cell;
    }
    else if(kSectionImage == indexPath.section)
    {
        static UIImage * noImageForCard       = nil;
        static dispatch_once_t onceToken      = 0;
        
        dispatch_once(&onceToken, ^{
            noImageForCard = [UIImage imageNamed: @"NoImageCard"];
        });

        MTGCardImageTableViewCell * cardImageCell = [tableView dequeueReusableCellWithIdentifier: @"Image"];
        if(nil == cardImageCell)
        {
            cardImageCell = [[MTGCardImageTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                             reuseIdentifier: @"Image"];
            cardImageCell.selectionStyle = UITableViewCellSelectionStyleNone;

            cardImageCell.cardImageView.userInteractionEnabled = YES;

            UITapGestureRecognizer *singleTapGesture =
                [[UITapGestureRecognizer alloc] initWithTarget: self
                                                        action: @selector(imageTapped:)];

            singleTapGesture.numberOfTapsRequired = 1;
            [cardImageCell.cardImageView addGestureRecognizer: singleTapGesture];
        }

        cell = cardImageCell;
        cell.contentView.backgroundColor = tableView.backgroundColor;

        __weak UIImageView * targetImageView = cardImageCell.cardImageView;
        weakify(self);
        [MTGCardImageHelper loadImage: card.multiverseId
                      targetImageView: targetImageView
                     placeholderImage: nil
                         didLoadBlock:^(UIImage *image, BOOL wasCached) {
                             strongify(self);

                             if(!wasCached)
                             {
                                 [UIView transitionWithView: targetImageView
                                                   duration: 1.0f
                                                    options: UIViewAnimationOptionTransitionFlipFromLeft
                                                 animations:^{[targetImageView setImage: image];}
                                                 completion: NULL];
                             }
                             else
                             {
                                 self->cardImage = image.copy;
                                 [targetImageView setImage: image];
                             }
                         } didFailBlock:^{
                             [UIView transitionWithView: targetImageView
                                               duration: 1.0f
                                                options: UIViewAnimationOptionTransitionFlipFromLeft
                                             animations:^{[targetImageView setImage: noImageForCard];}
                                             completion: NULL];
                         }];

        return cell;
    }
    else if(kSectionDescription == indexPath.section)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"Description"];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                          reuseIdentifier: @"Description"];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            [cell.textLabel setAttributedText: [card rulesAttributedString]];
        }
        
        return cell;
    }
    else if(kSectionFlavourText == indexPath.section)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"FlavourText"];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                          reuseIdentifier: @"FlavourText"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;

            UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits: UIFontDescriptorTraitItalic];
            cell.textLabel.font = [UIFont fontWithDescriptor:fontD
                                                        size:0];
        }
        
        cell.textLabel.text = card.flavorText ? card.flavorText : @"None";
        
        return cell;
    }
    else if(kSectionPricing == indexPath.section)
    {
        if(nil == priceDetails)
        {
            static NSString *LoadingCellIdentifier = @"LoadingCell";
            
            UITableViewCell * cell =
                [tableView dequeueReusableCellWithIdentifier: LoadingCellIdentifier];
            
            if (cell == nil)
            {
                cell =
                    [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: LoadingCellIdentifier];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            } // End of we did not have a cell

            cell.textLabel.text = NSLocalizedString(@"Loading", nil);

            return cell;
        } // End of loading
        else if(0 == priceDetails.count)
        {
            static NSString *NoPricesCellIdentifier = @"NoPricesCell";
            
            UITableViewCell * cell =
                [tableView dequeueReusableCellWithIdentifier: NoPricesCellIdentifier];
            
            if (cell == nil)
            {
                cell =
                    [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: NoPricesCellIdentifier];

                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            } // End of we did not have a cell

            cell.textLabel.text = NSLocalizedString(@"No prices available", nil);

            return cell;
        }
        else
        {
            static NSString *PricesCellIdentifier = @"PricesCell";
            
            MTGCardPriceTableViewCell * cell =
                [tableView dequeueReusableCellWithIdentifier: PricesCellIdentifier];

            if (cell == nil)
            {
                cell =
                    [[MTGCardPriceTableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                                     reuseIdentifier: PricesCellIdentifier];

                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            } // End of we did not have a cell

            MTGCardPriceDetails * priceDetailEntry = priceDetails[indexPath.row];
            cell.textLabel.text = priceDetailEntry.supplierName;
            cell.detailTextLabel.text = priceDetailEntry.condition;
            cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
            cell.priceTextLabel.text = [NSString stringWithFormat: @"$%@", priceDetailEntry.price];
            cell.priceTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.250];

            return cell;
        }
    } // End of pricing
    else if(kSectionCollections == indexPath.section)
    {
        if(indexPath.row >= [Deck decks].count)
        {
            static NSString * AddCollectionCellIdentifier = @"AddCollectionCell";
            
            UITableViewCell * cell =
                [tableView dequeueReusableCellWithIdentifier: AddCollectionCellIdentifier];
            
            if (cell == nil)
            {
                cell =
                    [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: AddCollectionCellIdentifier];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            } // End of we did not have a cell

            cell.textLabel.text = NSLocalizedString(@"New collection", nil);

            return cell;
        }
        else
        {
            static NSString *CellIdentifier = @"DeckCard";
            Deck * deck = [Deck decks][indexPath.row];

            DeckCardModifierCell * cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
            if(nil == cell)
            {
                cell = [[DeckCardModifierCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                                   reuseIdentifier:CellIdentifier];
                cell.delegate = self;
                cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            NSUInteger cardIndex = [deck.cards indexOfObjectPassingTest:^BOOL(MTGCardInDeck* _Nonnull deckCard, NSUInteger idx, BOOL * _Nonnull stop) {

                if(deckCard.multiverseId == self->card.multiverseId)
                {
                    *stop = YES;
                    return YES;
                }

                return NO;
            }];

            MTGCardInDeck * deckCard = nil;
            if(NSNotFound != cardIndex)
            {
                deckCard = deck.cards[cardIndex];
            }

            cell.multiverseId = deckCard.multiverseId;

            cell.textLabel.text = deck.deckName;
            cell.detailTextLabel.text = [NSString stringWithFormat: @"Contains %ldx %@", deckCard ? (long)deckCard.count : 0, card.name];
            
            return cell;
        }
    }

    cell = [tableView dequeueReusableCellWithIdentifier: @"ImageView"];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                      reuseIdentifier: @"ImageView"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (CGFloat) tableView: (UITableView *)tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if(kSectionImage == indexPath.section)
    {
        return 200.0f;
    }
    else if(kSectionDetails == indexPath.section)
    {
        return 24.0f;
    }
    else if(kSectionDescription == indexPath.section)
    {
        return UITableViewAutomaticDimension;
    }
    else if(kSectionFlavourText == indexPath.section)
    {
        return UITableViewAutomaticDimension;
    }

    return 44.0f;
}

- (CGFloat)            tableView: (UITableView *) tableView
estimatedHeightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    if(kSectionDescription == indexPath.section)
    {
        NSString * description = card.description;
        CGSize textSize = [description sizeWithFont:[UIFont systemFontOfSize:14.0f]
                                  constrainedToSize: CGSizeMake(self.view.frame.size.width - (8 * 3), 1000.0f)];

        return textSize.height;
    }
    else if(kSectionFlavourText == indexPath.section)
    {
        NSString * text = card.flavorText ? card.flavorText : @"None";
        CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize:14.0f]
                           constrainedToSize: CGSizeMake(self.view.frame.size.width - (8 * 3), 1000.0f)];

        return textSize.height;
    }
    
    return 44.0f;
} // End of tableView:estimatedHeightForRowAtIndexPath:

- (void) tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    lastSelectedIndexPath = indexPath.copy;

    [tableView deselectRowAtIndexPath: indexPath
                             animated: YES];

    if(kSectionPricing == indexPath.section)
    {
        if(priceDetails.count)
        {
            MTGCardPriceDetails * priceDetailEntry = priceDetails[indexPath.row];
            NSURL * webURL = [NSURL URLWithString: priceDetailEntry.link];
            [[UIApplication sharedApplication] openURL: webURL];
        } // End of we have priceDetails
    } // End of pricing
    else if(kSectionDetails == indexPath.section)
    {
        // bring up editing menu.
        UIMenuController *menu = [UIMenuController sharedMenuController];

        menu.menuItems = @[
                           [[UIMenuItem alloc] initWithTitle: @"Copy"
                                                      action: @selector(copyDetailsCell:)]];

        CGRect selectionRect = [tableView rectForRowAtIndexPath: indexPath];

        [menu setTargetRect: selectionRect
                     inView: tableView];

        [menu setMenuVisible: YES
                    animated: YES];
    }
    else if(kSectionCollections == indexPath.section)
    {
        if(indexPath.row >= [Deck decks].count)
        {
            Deck * deck = [[Deck alloc] init];
            [deck setDeckName: @"New Collection"];

            // Adds a new deck
            [[Deck decks] addObject: deck];
            [Deck saveDecks];
            [tableView reloadData];
        }
        else
        {
            EditDeckViewController * editDeckViewController = [[EditDeckViewController alloc] init];

            // Set our deck
            editDeckViewController.deck = [[Deck decks] objectAtIndex: indexPath.row];
            editDeckViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController: editDeckViewController animated:YES];
        }
    }
} // End of tableView:didSelectRowAtIndexPath:

#if todo
- (BOOL) tableView: (UITableView *) tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(kSectionDetails == indexPath.section)
    {
        return YES;
    }
    
    return NO;
}

-(BOOL) tableView: (UITableView *) tableView
 canPerformAction: (SEL) action
forRowAtIndexPath: (NSIndexPath *)indexPath
       withSender: (id)sender
{
    if(action == @selector(copy:))
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        // do stuff
    }
    
    return YES;
}

#endif

#pragma mark -
#pragma mark Gesture

- (void) imageTapped: (UITapGestureRecognizer*) gestureRecognizer
{
    if(gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        return;
    }

    UIImageView * imageView = (UIImageView*)gestureRecognizer.view;
    if(nil == imageView.image)
    {
        return;
    } // End of no image

    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    vc.liftedImageView = imageView;
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

#pragma mark -
#pragma mark DeckCard

- (void) deckCardModifierIncrease: (DeckCardModifierCell*) sender
{
    NSIndexPath * indexPath = [detailsTableView indexPathForCell: sender];
    Deck * deck = [[Deck decks] objectAtIndex: indexPath.row];
    [deck addCard: self.card];

    [Deck saveDecks];
    [detailsTableView reloadData];
}

- (void) deckCardModifierDecreased: (DeckCardModifierCell*) sender
{
    NSIndexPath * indexPath = [detailsTableView indexPathForCell: sender];

    Deck * deck = [[Deck decks] objectAtIndex: indexPath.row];
    [deck removeCard: self.card
        allowRemoval: NO];

    [Deck saveDecks];
    [detailsTableView reloadData];
}

@end

//
//  FirstViewCustomself.m
//  Scandit
//
//  Created by Chaman Sharma on 08/01/13.
//  Copyright (c) 2013 umar chhipa. All rights reserved.
//

#import "ListCardCustomCell.h"
#import "GGFullscreenImageViewController.h"
#import "MTGCard.h"
#import "MTGCardSet.h"
#import "MTGCardSetIconHelper.h"
#import "MTGPriceManager.h"
#import "MTGCardImageHelper.h"

@interface ListCardCustomCell()
{
    IBOutlet UILabel  * castingCostLabel;
}
@end

@implementation ListCardCustomCell
{
    NSLayoutConstraint      * castingCostHeightConstraint;
}

@synthesize cardImageView,cardNameLabel,typeLabel,rulesLabel;
@synthesize cardCollectorsNumberLabel;
@synthesize lowPriceLabel, mediumPriceLabel, highPriceLabel;

- (void) awakeFromNib
{
    [super awakeFromNib];

    [cardImageView setUserInteractionEnabled: YES];

    UITapGestureRecognizer *singleTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(imageTapped:)];

    singleTapGesture.numberOfTapsRequired = 1;
    [cardImageView addGestureRecognizer: singleTapGesture];
    
    rulesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [rulesLabel.topAnchor constraintEqualToAnchor: typeLabel.bottomAnchor].active = YES;
    [rulesLabel.leftAnchor constraintEqualToAnchor: cardNameLabel.leftAnchor].active = YES;
    [rulesLabel.rightAnchor constraintEqualToAnchor: typeLabel.rightAnchor].active = YES;
    [rulesLabel.heightAnchor constraintLessThanOrEqualToConstant: 50.0f].active = YES;
/*
    rulesLabel.layer.borderColor = [UIColor redColor].CGColor;
    rulesLabel.layer.borderWidth = 1;

    typeLabel.layer.borderColor = [UIColor blueColor].CGColor;
    typeLabel.layer.borderWidth = 1;
*/
    castingCostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [castingCostLabel.rightAnchor constraintEqualToAnchor: cardCollectorsNumberLabel.leftAnchor].active = YES;
    [castingCostLabel.centerYAnchor constraintEqualToAnchor: cardCollectorsNumberLabel.centerYAnchor].active = YES;
    [castingCostLabel.heightAnchor constraintEqualToConstant: 19.0f].active = YES;
}

- (void) imageTapped: (UITapGestureRecognizer*) gestureRecognizer
{
    if(gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        return;
    }

    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    vc.liftedImageView = cardImageView;
    [self.window.rootViewController presentViewController: vc
                                                 animated: YES
                                               completion: nil];
}

- (void) populateWithCard: (MTGCard*) card
                indexPath: (NSIndexPath*) indexPath
{
    static NSURL * baseURL = nil;
    static UIImage * darkBackgroundImage  = nil;
    static UIImage * lightBackgroundImage = nil;
    static UIImage * noImageForCard       = nil;
    static UIImage * backOfCardImage      = nil;
    static dispatch_once_t onceToken      = 0;
    dispatch_once(&onceToken, ^{
        backOfCardImage = [UIImage imageNamed: @"BackOfMagicCard"];
        darkBackgroundImage = [UIImage imageNamed: @"dark.png"];
        lightBackgroundImage = [UIImage imageNamed: @"light.png"];
        noImageForCard = [UIImage imageNamed: @"NoImageCard"];

        NSString * path = [[NSBundle mainBundle] bundlePath];
        baseURL = [NSURL fileURLWithPath: path];
    });

    self.cardNameLabel.text = card.name;

    NSString * tempString = card.description;

    tempString = [card.description stringByReplacingOccurrencesOfString: @"\r"
                                                             withString: @""];
    
    tempString = [tempString stringByReplacingOccurrencesOfString: @"\n"
                                                       withString: @" "];
    
    [self.rulesLabel setAttributedText: [card rulesAttributedString]];

    __weak UIImageView * targetImageView = self.cardImageView;
    [MTGCardImageHelper loadImage: card.multiverseId
                  targetImageView: targetImageView
                 placeholderImage: backOfCardImage
                     didLoadBlock:^(UIImage *image, BOOL wasCached) {
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
                             [targetImageView setImage: image];
                         }
                     } didFailBlock:^{
                         [UIView transitionWithView: targetImageView
                                           duration: 1.0f
                                            options: UIViewAnimationOptionTransitionFlipFromLeft
                                         animations:^{[targetImageView setImage: noImageForCard];}
                                         completion: NULL];
                     }];

    MTGPriceForCard * cardPrice = [MTGPriceManager priceForMultiverseId: card.multiverseId];
    self.lowPriceLabel.text     = [self displayForPrice: cardPrice.lowPrice];
    self.mediumPriceLabel.text  = [self displayForPrice: cardPrice.mediumPrice];
    self.highPriceLabel.text    = [self displayForPrice: cardPrice.highPrice];

    // No power or toughness, just set the type
    if(!card.power && !card.toughness)
    {
        self.typeLabel.text = card.type;
    }
    else
    {
        NSString * typeDisplay =
            [NSString stringWithFormat: @"%@ (%ld/%ld)", card.type,
             (long) (card.power ? card.power.integerValue : 0),
             (long) (card.toughness ? card.toughness.integerValue : 0)];

        self.typeLabel.text = typeDisplay;
    }

    castingCostLabel.attributedText = [card castingCostAttributedString];
    [castingCostLabel sizeToFit];



    if(nil != card.collectorsNumber && 0 != card.collectorsNumber.integerValue)
    {
        self.cardCollectorsNumberLabel.text =
            [NSString stringWithFormat: @"#%@", card.collectorsNumber.stringValue];
    }
    else
    {
        self.cardCollectorsNumberLabel.text = @"";
    }

    MTGCardSet * cardSet = [MTGCardSet cardSetById: card.cardSetId];

    self.setImageView.image = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * iconImage =
            [MTGCardSetIconHelper iconForCardSet: cardSet
                                      rarity: card.rarity];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.setImageView.image = iconImage;
        });
    });

    UIImage * backgroundImage = nil;
    if((indexPath.row%2)==0)
    {
        backgroundImage = darkBackgroundImage;
    }
    else
    {
        backgroundImage = lightBackgroundImage;
    }

    // Create if needed
    UIImageView * backgroundImageView = (id) self.backgroundView;
    if(nil == backgroundImageView)
    {
        backgroundImageView = [[UIImageView alloc] init];;
        self.backgroundView = backgroundImageView;
    }

    backgroundImageView.image = backgroundImage;
}

- (NSString*) displayForPrice: (NSNumber*) price
{
    if(price.integerValue > 1000)
    {
        return  [NSString stringWithFormat: @"%ld", (long) price.integerValue];
    }

    return [NSString stringWithFormat: @"%0.2f", price.floatValue];
} // End of displayForPrice

- (NSAttributedString*) nameAndCostAttributedString: (MTGCard*) card
{
    NSMutableAttributedString * outString = [[NSMutableAttributedString alloc] init];
    NSAttributedString * nameAttributedString =
        [[NSAttributedString alloc] initWithString: card.name
                                        attributes: @{}];

    [outString appendAttributedString: nameAttributedString];
    
    NSMutableAttributedString * castingCostAttributedString = [card castingCostAttributedString].mutableCopy;
    
    [castingCostAttributedString enumerateAttribute: NSAttachmentAttributeName
                                            inRange: NSMakeRange(0,castingCostAttributedString.length)
                                            options: 0
                                         usingBlock: ^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
         NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
         paragraphStyle.alignment                = NSTextAlignmentRight;
         [castingCostAttributedString addAttribute: NSParagraphStyleAttributeName
                                             value: paragraphStyle
                                             range: NSMakeRange(0, castingCostAttributedString.length)];
    }];

    [outString appendAttributedString: castingCostAttributedString];

    return outString;
} // End of

- (void) startAnimating
{
    
}

- (void) stopAnimating: (BOOL) spinnerOnly
{
    
}

@end

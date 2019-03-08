//
//  MTGLifeCounterSettingsViewController.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterSettingsViewController.h"
#import <XLForm/XLForm.h>
#import "MTGLifeCounter.h"

#define kStartingLife                   @"Starting life"
#define kNumberOfPlayers                @"Players"
#define kPoisonCountersEnabled          @"PoisonCountersEnabled"
#define kEDHEnabled                     @"EDHEnabled"
#define kResetGameButton                @"Reset"

#define kIdleTimerDisabled              @"idleTimerDisabled"

#define kGameRoomEnabled                @"gameRoomEnabled"
#define kGameRoomName                   @"gameRoomName"

@interface MTGLifeCounterSettingsViewController ()

@end

@implementation MTGLifeCounterSettingsViewController

- (id) init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle: @"Settings"];
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = NO;
    
    section = [XLFormSectionDescriptor formSectionWithTitle: @"General"];
    [formDescriptor addFormSection: section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag: kStartingLife
                                                rowType: XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title: @"Starting life"];
    row.value = @(MTGLifeCounter.sharedInstance.defaultLifeTotal);
    row.selectorOptions = @[@(10), @(20), @(30), @(40), @(50), @(100)];
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        MTGLifeCounter.sharedInstance.defaultLifeTotal = [newValue integerValue];
        [MTGLifeCounter.sharedInstance save];

        // No need to update any changes -- Default life counter does not cause any updates
        // until a reset button is pressed.
        // [self.delegate lifeCounterSettingsDidChange: self];
    };

    [section addFormRow: row];

    // Number of players
    row = [XLFormRowDescriptor formRowDescriptorWithTag: kNumberOfPlayers
                                                rowType: XLFormRowDescriptorTypeSelectorSegmentedControl
                                                  title: @"Players"];
    [section addFormRow: row];
    row.value = @(MTGLifeCounter.sharedInstance.numberOfPlayers);
    row.selectorOptions = @[@(2), @(3), @(4), @(5), @(6), @(7), @(8)];
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        // Set our new value
        MTGLifeCounter.sharedInstance.numberOfPlayers = [newValue integerValue];
        [self updatePlayersSection];
        [MTGLifeCounter.sharedInstance save];

        [self.delegate lifeCounterSettingsDidChange: self];
    };

    // Poison counters
    row = [XLFormRowDescriptor formRowDescriptorWithTag: kPoisonCountersEnabled
                                                rowType: XLFormRowDescriptorTypeBooleanSwitch
                                                  title: @"Poison enabled"];
    row.value = @(MTGLifeCounter.sharedInstance.poisonEnabled);
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        MTGLifeCounter.sharedInstance.poisonEnabled = [newValue boolValue];
        [MTGLifeCounter.sharedInstance save];

        [self.delegate lifeCounterSettingsDidChange: self];
    };
    [section addFormRow: row];

    // EDH/Commander
    row = [XLFormRowDescriptor formRowDescriptorWithTag: kEDHEnabled
                                                rowType: XLFormRowDescriptorTypeBooleanSwitch
                                                  title: @"Commander/EDH enabled"];
    row.value = @(MTGLifeCounter.sharedInstance.commanderEnabled);
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        MTGLifeCounter.sharedInstance.commanderEnabled = [newValue boolValue];
        [MTGLifeCounter.sharedInstance save];
        
        [self.delegate lifeCounterSettingsDidChange: self];
    };
    [section addFormRow: row];

    section = [XLFormSectionDescriptor formSectionWithTitle: @"Players"];
    [formDescriptor addFormSection: section];

    section = [XLFormSectionDescriptor formSectionWithTitle: @"Misc"];
    section.footerTitle = @"With the lock screen disabled, your device will not lock as long as the life counter is visible.";
    [formDescriptor addFormSection:section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag: kIdleTimerDisabled
                                                rowType: XLFormRowDescriptorTypeBooleanSwitch
                                                  title: @"Lock screen disabled"];

    BOOL disableIdleTimer = [[NSUserDefaults standardUserDefaults] boolForKey: kMTGLockScreenIdleTimerDisabled];
    row.value = @(disableIdleTimer);
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        [[NSUserDefaults standardUserDefaults] setBool: [newValue boolValue]
                                                forKey: kMTGLockScreenIdleTimerDisabled];
    };
    [section addFormRow: row];

    
    
    
    
#if DEBUG
    section = [XLFormSectionDescriptor formSectionWithTitle: @"Game room"];
    section.footerTitle = @"Joining a game room will allow all players in the same room to view and update the game state. Whenever a player updates the game state, all players life counters will update.";
    [formDescriptor addFormSection: section];

    row = [XLFormRowDescriptor formRowDescriptorWithTag: kGameRoomEnabled
                                                rowType: XLFormRowDescriptorTypeBooleanSwitch
                                                  title: @"Enabled"];

    BOOL gameRoomEnabled = [MTGLifeCounter sharedInstance].gameRoomEnabled;
    row.value = @(gameRoomEnabled);
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        [[NSUserDefaults standardUserDefaults] setBool: [newValue boolValue]
                                                forKey: kMTGLockScreenIdleTimerDisabled];
    };
    [section addFormRow: row];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag: kGameRoomName
                                                rowType: XLFormRowDescriptorTypeText
                                                  title: @"Room name"];

    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.value = [MTGLifeCounter sharedInstance].gameRoomName;
    row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
        [MTGLifeCounter.sharedInstance save];
        [self.delegate lifeCounterSettingsDidChange: self];
    };

    [section addFormRow: row];
#endif

    section = [XLFormSectionDescriptor formSectionWithTitle: @"Actions"];
    [formDescriptor addFormSection:section];
    
    // Save
    row = [XLFormRowDescriptor formRowDescriptorWithTag: kResetGameButton
                                                rowType: XLFormRowDescriptorTypeButton
                                                  title: NSLocalizedString(@"Reset game", nil)];

    row.action.formBlock = ^(XLFormRowDescriptor * descriptor) {
        [self.tableView setEditing: NO
                          animated:YES];

        // Reset our game state and save
        [MTGLifeCounter.sharedInstance resetGameState];
        [MTGLifeCounter.sharedInstance save];

        [self.delegate lifeCounterSettingsDidChange: self];

        UIImpactFeedbackGenerator * feedbackGenerator =
        [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
        [feedbackGenerator impactOccurred];
    };
    
    [section addFormRow: row];

    self = [super initWithForm: formDescriptor];
    
    if(self)
    {
        self.title = NSLocalizedString(@"Settings",  nil);
        self.tabBarItem.title = NSLocalizedString(@"Settings",  nil);
        self.tabBarItem.image = [UIImage imageNamed: @"TabBar-Settings"];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self updatePlayersSection];
}

- (void) updatePlayersSection
{
    XLFormSectionDescriptor * playersSection = nil;
    for(XLFormSectionDescriptor * section in self.form.formSections)
    {
        if([section.title isEqualToString: @"Players"])
        {
            playersSection = section;
            break;
        }
    }

    if(nil == playersSection)
    {
        return;
    } // End of no playersSection

    NSMutableArray<NSIndexPath*>* rowsToRemove = @[].mutableCopy;
    while(playersSection.formRows.count > MTGLifeCounter.sharedInstance.numberOfPlayers)
    {
        XLFormRowDescriptor * lastObject = playersSection.formRows.lastObject;
        [rowsToRemove addObject: [self.form indexPathOfFormRow: lastObject]];
        [playersSection.formRows removeObject: lastObject];
    } // End of rowsToRemove

    if(rowsToRemove.count)
    {
        [self.tableView deleteRowsAtIndexPaths: rowsToRemove
                              withRowAnimation: UITableViewRowAnimationAutomatic];
    } // End of we have rows to remove

    NSUInteger playerIndex = playersSection.formRows.count;
    while(playersSection.formRows.count < MTGLifeCounter.sharedInstance.numberOfPlayers)
    {
        NSString * tag = [NSString stringWithFormat: @"Player %lu", (unsigned long) (playerIndex + 1)];
        MTGPlayer * player = MTGLifeCounter.sharedInstance.players[playerIndex];

        XLFormRowDescriptor* row = [XLFormRowDescriptor formRowDescriptorWithTag: tag
                                                                         rowType: XLFormRowDescriptorTypeText
                                                                           title: tag];

        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        row.value = player.name;
        row.onChangeBlock = ^(id  _Nullable oldValue, id  _Nullable newValue, XLFormRowDescriptor * _Nonnull rowDescriptor) {
            NSIndexPath * updatedIndexPath = [self.form indexPathOfFormRow: rowDescriptor];
            MTGPlayer * player = MTGLifeCounter.sharedInstance.players[updatedIndexPath.item];
            // Update our players name
            player.name = newValue;

            [MTGLifeCounter.sharedInstance save];
            [self.delegate lifeCounterSettingsDidChange: self];
        };

        [playersSection addFormRow: row];

        ++playerIndex;
    }
}

- (void) didSelectFormRow: (XLFormRowDescriptor *) formRow
{
    [super didSelectFormRow:formRow];
    
    if ([formRow.tag isEqual: kResetGameButton])
    {
        [self deselectFormRow:formRow];
    }
}

@end

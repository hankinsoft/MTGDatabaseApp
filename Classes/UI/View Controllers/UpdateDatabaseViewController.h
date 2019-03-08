//
//  UpdateDatabaseViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2012-10-04.
//
//

#import <UIKit/UIKit.h>

typedef void (^DatabaseReadyBlock) (NSString * databasePath);

@class MBProgressHUD;

@interface UpdateDatabaseViewController : UIViewController
{
    MBProgressHUD       * progressHUD;

    NSMutableData       * responseData;
    long long           expectedLength;
} // End of UpdateDatabaseViewController

@property(nonatomic,copy) DatabaseReadyBlock onDatabaseReady;

@end

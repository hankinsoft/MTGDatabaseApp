//
//  UpdateDatabaseViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2012-10-04.
//
//

#import "UpdateDatabaseViewController.h"
#import "MBProgressHUD.h"

@interface UpdateDatabaseViewController ()

@end

@implementation UpdateDatabaseViewController

@synthesize onDatabaseReady;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        responseData = [NSMutableData data];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    // The hud will dispable all input on the view
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
	
    // Add HUD to screen
    [self.view addSubview:progressHUD];
    
    progressHUD.labelText = @"Updating Database";
    progressHUD.mode = MBProgressHUDModeDeterminate;
    [progressHUD setRemoveFromSuperViewOnHide:YES];

    // Show the progress HUD
    [progressHUD show: YES];

    // NSURLConnection needs to run on the main thread
    [self performSelectorOnMainThread: @selector(updateDatabase) withObject: nil waitUntilDone: NO];
} // End of viewWillAppear

- (void) updateDatabase
{
    NSURL *url = [NSURL URLWithString: @"http://www.magicthegatheringdatabase.com/database.zip"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 20];

    [request setHTTPMethod:@"GET"];
    NSURLConnection * result = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(nil == result)
    {
        NSLog(@"No result");
    }
} // End of beginSearch

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error!: %@", error.localizedDescription);
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedLength = response.expectedContentLength;
    NSLog(@"Expected length is: %lld", expectedLength);
    [responseData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
    progressHUD.progress = (float)responseData.length / (float)expectedLength;
} // End of didReceiveData

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
#if todo
    // Write to temp directory
    // We need to unzip the file
    CkoZip *zip = [[CkoZip alloc] init];
    zip.VerboseLogging = YES;
    zip.DiscardPaths = YES;
    zip.TempDir      = NSTemporaryDirectory();

    if(![zip UnlockComponent: @"KYLHNKZIP_7FAxZSC92Ppx"])
    {
        NSLog(@"Unable to unlock component: %@", zip.LastErrorText);
        return;
    }

    if(![zip OpenFromMemory: responseData])
    {
        NSLog(@"Error");
        return;
    }

    // Unzip to the temp directory
    NSInteger totalFiles = [zip Unzip: NSTemporaryDirectory()].integerValue;
    if(0 == totalFiles)
    {
        NSLog(@"Unable to extract any files.");
        return;
    }
    
    // Close our zip
    [zip CloseZip];

    NSString * database = [NSString stringWithFormat: @"%@/db.sqlite", NSTemporaryDirectory()];
    if(nil != onDatabaseReady)
    {
        onDatabaseReady(database);
    } // End of our database is finished

    // Dismiss our update screen
    [self dismissViewControllerAnimated: YES
                             completion: ^{}];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  MTGArtists.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-04-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGArtist.h"

@interface MTGArtist()

@property(nonatomic,assign) NSInteger artistId;
@property(nonatomic,copy)   NSString * name;

@end

@implementation MTGArtist

static NSArray<MTGArtist*>* _allArtists = nil;
static HSSemaphore * loadingSemaphore = nil;

+ (void) initialize
{
    loadingSemaphore = [[HSSemaphore alloc] initWithIdentifier: @"com.mtg.artist.loadingSemaphore"
                                                  initialValue: 1];
}

+ (NSArray<MTGArtist*>*) allArtists
{
    if(nil == _allArtists)
    {
        [loadingSemaphore wait: DISPATCH_TIME_FOREVER];

        // Double check. Maybe we were waiting for the artists to finish loading.
        if(nil != _allArtists)
        {
            return _allArtists;
        }

        NSArray * artists = [self loadAllArtists];
        _allArtists = artists;

        [loadingSemaphore signal];
    } // End of artists are not loaded
    
    return _allArtists;
} // End of _allArtists

+ (NSArray<MTGArtist*>*) loadAllArtists
{
    __block NSMutableArray<MTGArtist*>* artists = @[].mutableCopy;
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        NSString * landQuery = @"SELECT artistId, name FROM artist";
        
        FMResultSet * results = [database executeQuery: landQuery];
        
        while ([results next])
        {
            MTGArtist * artist = [[MTGArtist alloc] init];
            artist.artistId = [results intForColumn: @"artistId"];
            artist.name = [results stringForColumn: @"name"];

            [artists addObject: artist];
        }
    }];// End of query
    
    [artists sortUsingComparator:^NSComparisonResult(MTGArtist *  _Nonnull obj1, MTGArtist * _Nonnull obj2) {
        if(obj1.artistId == obj2.artistId)
        {
            return NSOrderedSame;
        }
        else if(obj1.artistId < obj2.artistId)
        {
            return NSOrderedAscending;
        }
        
        return NSOrderedDescending;
    }];
    
    return artists;
} // End of loadAllArtists

+ (MTGArtist*) artistById: (NSUInteger) artistId
{
    MTGArtist * searchObject = [[MTGArtist alloc] init];
    searchObject.artistId = artistId;
    
    NSArray * searchArtists = self.allArtists;
    NSRange searchRange = NSMakeRange(0, searchArtists.count);
    NSUInteger findIndex = [searchArtists indexOfObject: searchObject
                                          inSortedRange: searchRange
                                                options: NSBinarySearchingFirstEqual
                                        usingComparator: ^(MTGArtist * obj1, MTGArtist * obj2)
                            {
                                if(obj1.artistId == obj2.artistId)
                                {
                                    return NSOrderedSame;
                                }
                                else if(obj1.artistId < obj2.artistId)
                                {
                                    return NSOrderedAscending;
                                }
                                
                                return NSOrderedDescending;
                            }];

    if(NSNotFound == findIndex)
    {
        return nil;
    }

    // Return our found entry
    return searchArtists[findIndex];
} // End of artistById:

@end

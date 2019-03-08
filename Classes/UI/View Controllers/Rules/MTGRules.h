//
//  MTGRules.h
//  Generated by JSON Toolbox - http://itunes.apple.com/app/json-toolbox/id525015412
//
//  Created by kylehankinson on Jun 5, 2012
//

#import <Foundation/Foundation.h>

#if ! __has_feature(objc_arc)
	#define JSONAutoRelease(param) ([param autorelease]);
#else
	#define JSONAutoRelease(param) (param)
#endif

@class Children;

@interface MTGRules : NSObject
{
} // End of MTGRules

+ (NSArray*) MTGRulesWithArray: (NSArray*) array;
+ (NSArray*) MTGRulesArrayWithJSONString: (NSString *) jsonString usingEncoding: (NSStringEncoding) stringEncoding error: (NSError**) error;
+ (MTGRules *)MTGRulesWithDictionary: (NSDictionary *) dictionary;
+ (MTGRules *)MTGRulesWithJSONString: (NSString *) jsonString usingEncoding: (NSStringEncoding) stringEncoding error: (NSError**) error;
- (id)initWithDictionary: (NSDictionary *) dictionary;
- (NSString*) description;

@property(nonatomic, retain) NSString * section;
@property(nonatomic, retain) NSString * text;
@property(nonatomic, retain) NSArray * children;

@end
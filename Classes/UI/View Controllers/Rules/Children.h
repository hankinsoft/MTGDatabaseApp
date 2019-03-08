//
//  Children.h
//  Generated by JSON Toolbox - http://itunes.apple.com/app/json-toolbox/id525015412
//
//  Created by kylehankinson on Jun 5, 2012
//

#import <Foundation/Foundation.h>

@class Children;

@interface Children : NSObject
{
} // End of Children

+ (NSArray*) ChildrenWithArray: (NSArray*) array;
+ (NSArray*) ChildrenArrayWithJSONString: (NSString *) jsonString usingEncoding: (NSStringEncoding) stringEncoding error: (NSError**) error;
+ (Children *)ChildrenWithDictionary: (NSDictionary *) dictionary;
+ (Children *)ChildrenWithJSONString: (NSString *) jsonString usingEncoding: (NSStringEncoding) stringEncoding error: (NSError**) error;
- (id)initWithDictionary: (NSDictionary *) dictionary;
- (NSString*) description;

@property(nonatomic, retain) NSString * section;
@property(nonatomic, retain) NSString * text;
@property(nonatomic, retain) NSArray * children;

@end
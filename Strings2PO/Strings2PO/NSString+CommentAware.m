//
//  NSString+CommentAware.m
//  Strings2PO
//
//  Created by Brant Merryman on 10/14/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "NSString+CommentAware.h"



@implementation NSDictionary (Range)

+ (NSDictionary *)dictionaryWithRange:(NSRange)range
{
    return @{ @"location" : [NSNumber numberWithUnsignedInteger:range.location], @"length" : [NSNumber numberWithUnsignedInteger:range.length], @"RangeDictionary" : @YES };
}

- (NSRange)rangeFromDictionary
{
    id numBool = [self objectForKey:@"RangeDictionary"];
    NSAssert([numBool isKindOfClass: [NSNumber class]] && [numBool boolValue], @"Not a range dictionary");
    
    return NSMakeRange([[self objectForKey:@"location"] unsignedIntegerValue], [[self objectForKey:@"length"] unsignedIntegerValue]);
}

@end

@implementation NSString (CommentAware)

- (NSArray *)commentsRanges
{
    // create an array of indexes of comment start, then create an array of indexes to comment end, then match them up.
    NSMutableArray * begins = [NSMutableArray arrayWithCapacity:self.length / 2];
    NSMutableArray * ends = [NSMutableArray arrayWithCapacity:self.length / 2];
    
    NSRange searchRange = NSMakeRange(0, self.length);
    for (;;) {
        NSRange commentBeginRange = [self rangeOfString:@"/*" options:0 range: searchRange];
        if (NSNotFound == commentBeginRange.location) {
            break;
        }
        [begins addObject:[NSNumber numberWithUnsignedInteger:commentBeginRange.location]];
        searchRange = NSMakeRange(commentBeginRange.location + commentBeginRange.length, self.length - (commentBeginRange.location + (2 *commentBeginRange.length) ));
        
        NSRange commentEndRange = [self rangeOfString:@"*/" options: 0 range: searchRange];
        if (NSNotFound == commentEndRange.location) {
            break;
        }
        [ends addObject:[NSNumber numberWithUnsignedInteger:commentEndRange.location + commentEndRange.length]];
        searchRange = NSMakeRange(commentEndRange.location + commentEndRange.length, self.length - (commentEndRange.location + (2 * commentEndRange.length)));
    }
    NSAssert(begins.count == ends.count, @"Comment indexes appear to be unmatched.");
    
    NSMutableArray * comps = [NSMutableArray arrayWithCapacity:begins.count];
    for (NSUInteger i = 0; i < begins.count; ++i) {
        [comps addObject:[NSDictionary dictionaryWithRange: NSMakeRange([[begins objectAtIndex: i] unsignedIntegerValue], [[ends objectAtIndex: i] unsignedIntegerValue] - [[begins objectAtIndex: i] unsignedIntegerValue])]];
    }
    return [comps copy];
}

- (NSArray *)componentsSeparatedByStringNotCommentedOut:(NSString *)separator
{
    
    // first determine ranges to ignore.
    
    NSArray * comments = [self commentsRanges];

    
    NSRange r = [self rangeOfString:separator];
    
    if (NSNotFound == r.location) {
        
        return @[self];
    }
    
    
    
    
    
    NSMutableArray * comps = [NSMutableArray arrayWithCapacity:self.length / separator.length]; // yes, a zero length separator will blow up. That's ok.
    
    NSUInteger j = 0;
    for (__block NSUInteger i = 0; NSNotFound != r.location ; r = [self rangeOfString:separator options:0 range:NSMakeRange(i, self.length - i)]) {
        
        
        __block BOOL inComment = NO;
        
        // now look to see if the separator is in a comment and ignore otherwise.
        dispatch_apply(comments.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t index){
            NSRange cr = [[comments objectAtIndex:index] rangeFromDictionary];
            if (r.location > cr.location && r.location < cr.location + cr.length) {
                // in comment
                i = cr.location + cr.length;
                inComment = YES;
            }
        });
        
        if (inComment) {
            continue;
        }
        
        [comps addObject: [self substringWithRange: NSMakeRange(j, r.location - j) ] ];
        i = r.location + r.length;
        j = i;
    }
    
    return [comps copy];
}

@end

//
//  NSString+CommentAware.h
//  Strings2PO
//
//  Created by Brant Merryman on 10/14/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Range)

+ (NSDictionary *)dictionaryWithRange:(NSRange)range;

- (NSRange)rangeFromDictionary;

@end

@interface NSString (CommentAware)

- (NSArray *)commentsRanges;

- (NSArray *)componentsSeparatedByStringNotCommentedOut:(NSString *)separator;

@end

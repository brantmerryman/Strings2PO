//
//  NSDictionary+DotStrings.h
//  Strings2PO
//
//  Created by Brant Merryman on 10/22/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DotStrings)

- (void)writeToStringsFile:(NSString *)filePath;

@end

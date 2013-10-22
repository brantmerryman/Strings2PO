//
//  NSDictionary+DotStrings.m
//  Strings2PO
//
//  Created by Brant Merryman on 10/22/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "NSDictionary+DotStrings.h"

@implementation NSDictionary (DotStrings)

- (void)writeToStringsFile:(NSString *)filePath withEncoding:(NSStringEncoding)encoding
{
    // estimate the capacity needed.
    NSError * err = nil;
    BOOL fDir;
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath: [filePath stringByDeletingLastPathComponent] isDirectory:&fDir] && fDir, @"Invalid filePath");
    
    NSAssert(![[NSFileManager defaultManager] fileExistsAtPath: filePath isDirectory:&fDir] || !fDir, @"Can't overwrite a directory");
    
    
    NSUInteger capacity = 10;
    
    for (id key in [self allKeys]) {
        id value = [self objectForKey:key];
        capacity += [key description].length;
        capacity += [value description].length;
        capacity += 9;
    }
    
    NSMutableString * destStr = [NSMutableString stringWithCapacity:capacity];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
        err = nil;
        if (err) {
            [NSException raise:@"Failed to remove existing file." format:@"%@", [err description]];
        }
    }

    for (id key in [self allKeys]) {
        id value = [self objectForKey:key];
        [destStr appendFormat:@"\"%@\" = \"%@\";\n", key, value];
    }
    
    err = nil;
    [destStr writeToFile:filePath atomically:YES encoding:encoding error:&err];

    
}

@end

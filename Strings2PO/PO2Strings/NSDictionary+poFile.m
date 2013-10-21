//
//  NSDictionary+poFile.m
//  Strings2PO
//
//  Created by Brant Merryman on 10/21/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "NSDictionary+poFile.h"

@implementation NSDictionary (poFile)


+ (NSDictionary *)dictionaryWithContentsOfPOFile:(NSString *)filePath
{
    NSMutableDictionary * interResult = [NSMutableDictionary dictionaryWithCapacity:1000];
    NSError * err = nil;
    NSString * contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%@", [err description]);
    }
    
//    const char * bytes = [contents UTF8String];
    
    NSUInteger iStartQuote;
    NSUInteger iEndQuote;
    NSUInteger i, len;
    
    for (NSRange r = [contents rangeOfString:@"msgid"];NSNotFound != r.location; r = [contents rangeOfString:@"msgid" options:0 range:NSMakeRange(r.location + r.length, contents.length - (r.location + r.length))]) {
        
        
        NSLog(@"msgid: %lu", r.location);
        
        // find start quote
        BOOL ignoreQuote = NO;
        
        iStartQuote = 0;
        for (i = 1 + r.location + r.length; 0==iStartQuote && i < contents.length;++i) {
            switch([contents characterAtIndex: i]) {
                case '"':
                    if (!ignoreQuote) {
                        iStartQuote = i;
                    }
                    ignoreQuote = NO;
                    break;
                    
                case '\\':
                    ignoreQuote = YES;
                    break;
                case '\n':
                    NSLog(@"Error at %lu", i);
                    continue;
                    break;
                default:
                    ignoreQuote = NO;
                    break;
            }
        }
        
        if ('"' != [contents characterAtIndex:iStartQuote]) {
            NSLog(@"Could not find start quote");
            continue;
        }
        
        iEndQuote = 0;
        ignoreQuote = NO;
        // find end quote
        for (i = iStartQuote +1; 0 == iEndQuote && i < contents.length; ++i ) {
            switch([contents characterAtIndex:i]) {
                case '"':
                    if (!ignoreQuote) {
                        iEndQuote = i;
                    }
                    ignoreQuote = NO;
                    break;
                    
                case '\\':
                    iEndQuote = YES;
                    break;
                case '\n':
                    NSLog(@"Error at %lu", i);
                    continue;
                    break;
                default:
                    iEndQuote = NO;
                    break;
            }
        }
        
        if ('"' != [contents characterAtIndex:iEndQuote]) {
            NSLog(@"Could not find end quote");
            continue;
        }
        // should be able to get the msgid contents now.
        len = iEndQuote - (iStartQuote +1);
        NSString * msgid_contents = [contents substringWithRange:NSMakeRange(iStartQuote+1, len)];
        NSLog(@"Start: %lu End: %lu length: %lu msgid contents: %@", iStartQuote, iEndQuote, len, msgid_contents);

        // find the msgstr
        
        r = [contents rangeOfString:@"msgstr" options:0 range:NSMakeRange(iEndQuote + 1, contents.length - (iEndQuote + 1))];
        

        
        NSLog(@"msgstr: %lu", r.location);

        
        // find start quote
        ignoreQuote = NO;
        iStartQuote = 0;
        
        for (i = 1+ r.location + r.length; 0==iStartQuote && i < contents.length;++i) {
            switch([contents characterAtIndex:i]) {
                case '"':
                    if (!ignoreQuote) {
                        iStartQuote = i;
                    }
                    ignoreQuote = NO;
                    break;
                    
                case '\\':
                    ignoreQuote = YES;
                    break;
                case '\n':
                    NSLog(@"Error at %lu", i);
                    continue;
                    break;
                default:
                    ignoreQuote = NO;
                    break;
            }
        }
        
        if ('"' != [contents characterAtIndex:iStartQuote]) {
            NSLog(@"Could not find start quote");
            continue;
        }
        
        ignoreQuote = NO;
        iEndQuote = 0;
        // find end quote
        for (i = iStartQuote +1; 0 == iEndQuote && i < contents.length; ++i ) {
            switch([contents characterAtIndex:i]) {
                case '"':
                    if (!ignoreQuote) {
                        iEndQuote = i;
                    }
                    ignoreQuote = NO;
                    break;
                    
                case '\\':
                    iEndQuote = YES;
                    break;
                case '\n':
                    NSLog(@"Error at %lu", i);
                    continue;
                    break;
                default:
                    iEndQuote = NO;
                    break;
            }
        }
        
        if ('"' != [contents characterAtIndex:iEndQuote]) {
            NSLog(@"Could not find end quote");
            continue;
        }
        
        len = iEndQuote - (iStartQuote +1);
        NSString * msgstr_contents = [contents substringWithRange:NSMakeRange(iStartQuote+1, len)];

        NSLog(@"Start: %lu End: %lu len: %lu msgstr contents: %@", iStartQuote, iEndQuote, len, msgstr_contents);
        
        [interResult setObject:msgstr_contents forKey:msgid_contents];
    }
    
    return [interResult copy];
    
}

@end

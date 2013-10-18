//
//  PO2StringsDelegate.m
//  PO2Strings
//
//  Created by Brant Merryman on 10/18/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "PO2StringsDelegate.h"

@implementation PO2StringsDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    stringsFiles = [NSMutableArray arrayWithCapacity:100];
    poFiles = [NSMutableArray arrayWithCapacity:100];
    poLocalizations = [NSMutableDictionary dictionaryWithCapacity:100];
}


- (void)processItem:(NSString *)filePath
{
    BOOL directory;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&directory]) {
        
        if (directory) {
            
            NSError * err = nil;
            NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&err];
            if (err) {
                NSLog(@"Error: %@ at %s(%d)", [err description], __FILE__, __LINE__);
            } else {
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                
                dispatch_apply(contents.count, q, ^(size_t i){
                    [self processItem: [filePath stringByAppendingPathComponent: [contents objectAtIndex: i]]];
                });
                
                
            }
            
            
        } else {
            if ([filePath hasSuffix:@".strings"]) {
                
                // add it to the list.
                @synchronized (stringsFiles) {
                    [stringsFiles addObject: filePath];
                }
            } else if ([filePath hasSuffix:@".po"]) {
                
                NSArray * comps = [[[filePath pathComponents] lastObject] componentsSeparatedByString:@"-"];
                
                if (comps && comps.count > 0 && 2 == [[comps objectAtIndex:0] length] ) {
                    NSString * localizationValue = [comps objectAtIndex:0];
                    [poLocalizations setObject:localizationValue forKey:filePath];
                    
                }
                
                @synchronized (poFiles) {
                    [poFiles addObject:filePath];
                }
            }
        }
        
        
    } else {
        // its not there??
        NSLog(@"File not found: %@", filePath);
    }
    
    
}

- (IBAction)addStringsFiles:(id)sender
{
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:YES];
    
    [op setAllowsMultipleSelection:YES];
    
    [op setAllowedFileTypes:@[@"strings"]];
    
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSInteger rc){
        
        if (1 != rc) { return; }
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply(op.URLs.count, q, ^(size_t i){
            [self processItem: [[op.URLs objectAtIndex: i] path]];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [stringsTable reloadData];
        });
        
    }];
}

- (IBAction)removeStringsFiles:(id)sender
{
    
    @synchronized (stringsFiles) {
        [stringsFiles removeObjectsAtIndexes:stringsTable.selectedRowIndexes];
    }
    
    [stringsTable reloadData];
    removeStrings.enabled = NO;

}

- (IBAction)addPOFiles:(id)sender
{
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:YES];
    
    [op setAllowsMultipleSelection:YES];
    
    [op setAllowedFileTypes:@[@"po"]];
    
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSInteger rc){
        
        if (1 != rc) { return; }
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply(op.URLs.count, q, ^(size_t i){
            [self processItem: [[op.URLs objectAtIndex: i] path]];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [poTable reloadData];
        });
        
    }];
}

- (IBAction)removePOFiles:(id)sender
{
    @synchronized (poFiles) {
        [poFiles removeObjectsAtIndexes:poTable.selectedRowIndexes];
    }
    
    [poTable reloadData];
    removePOs.enabled = NO;
}

- (IBAction)PO2Strings:(id)sender
{
    cancel = NO;
    [translationProgress setDoubleValue: 0.0];
    NSLog(@"%@", [self.window description]);
    [NSApp beginSheet:translationWorksheet modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
    [NSThread detachNewThreadSelector:@selector(translatePO2Strings:) toTarget:self withObject:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    
    [sheet orderOut:nil];
}

- (void)translatePO2Strings:(id)context
{
    @autoreleasepool {
        for (float i = 0; !cancel && i <= 100; i += 1.0) {
            usleep(40000);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [translationProgress setDoubleValue: i];
            });
        }
        
        if (!cancel) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [translationProgress setDoubleValue:100];
                localizationLabel.stringValue = @"Done";
            });
            
            usleep(40000);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [NSApp endSheet:translationWorksheet returnCode:1];
            });
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    
    if (tableView == stringsTable) {
        return stringsFiles.count;
    } else if (tableView == poTable) {
        return poFiles.count;
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == stringsTable) {
        return @{ @"filePath" : [stringsFiles objectAtIndex:row] };
    } else if (tableView == poTable) {
        if ([tableColumn.identifier isEqualToString:@"poFilePath"] ) {
            return @{ @"filePath" : [poFiles objectAtIndex:row] };
        } else {
            NSString * localization = @"";
            NSString * pofp = [poFiles objectAtIndex:row];
            id pol = [poLocalizations objectForKey:pofp];
            if (pol && [pol isKindOfClass:[NSString class]]) {
                localization = pol;
            }
            return @{ @"localization" : localization} ;
        }
    }
    return @"";
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"%@", [notification description]);
/*
    NSIndexSet * indexSet = stringsFilesTable.selectedRowIndexes;
    
    removeButton.enabled = (0 != indexSet.count);
*/
}

- (IBAction)CancelAction:(id)sender
{
    [NSApp endSheet:translationWorksheet];
    cancel = YES;
}

@end

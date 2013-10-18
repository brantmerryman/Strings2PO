//
//  PO2StringsDelegate.h
//  PO2Strings
//
//  Created by Brant Merryman on 10/18/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PO2StringsDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
    
    IBOutlet NSTableView * stringsTable;
    IBOutlet NSTableView * poTable;
    
    IBOutlet NSButton * removeStrings;
    IBOutlet NSButton * removePOs;
    
    
    NSMutableArray * poFiles;
    NSMutableArray * stringsFiles;
    
    NSMutableDictionary * poLocalizations;
    NSMutableDictionary * poNumberOfTranslationsPerFile;
    
    // translation sheet.
    
    IBOutlet NSWindow * translationWorksheet;
    IBOutlet NSProgressIndicator * translationProgress;
    IBOutlet NSTextField * localizationLabel;
    
    BOOL cancel;
    
}


- (IBAction)addStringsFiles:(id)sender;
- (IBAction)removeStringsFiles:(id)sender;

- (IBAction)addPOFiles:(id)sender;
- (IBAction)removePOFiles:(id)sender;

- (IBAction)PO2Strings:(id)sender;

- (IBAction)CancelAction:(id)sender;


@property (assign) IBOutlet NSWindow *window;


@end

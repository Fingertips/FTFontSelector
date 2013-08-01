//
//  FTFontSelectorController.h
//
//  Created by Eloy Durán on 7/26/13.
//  Copyright (c) 2013 Eloy Durán <eloy.de.enige@gmail.com>. All rights reserved.
//
//  Note: this will be extracted as a standalone OSS lib.

#import <UIKit/UIKit.h>

@class FTFontSelectorController;

@protocol FTFontSelectorControllerDelegate <NSObject>

- (void)fontSelectorController:(FTFontSelectorController *)controller
     didChangeSelectedFontName:(NSString *)fontName;

- (void)fontSelectorControllerShouldBeDismissed:(FTFontSelectorController *)controller;

@end

@interface FTFontSelectorController : UINavigationController

@property (weak) id<FTFontSelectorControllerDelegate> fontDelegate;

// The postscript name of the font.
@property (readonly) NSString *selectedFontName;

// The postscript name of the font.
- (instancetype)initWithSelectedFontName:(NSString *)fontName;

@end

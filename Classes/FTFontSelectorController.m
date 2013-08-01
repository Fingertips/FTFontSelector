//
//  FTFontSelectorController.m
//
//  Created by Eloy Durán on 7/26/13.
//  Copyright (c) 2013 Eloy Durán <eloy.de.enige@gmail.com>. All rights reserved.
//
//  Note: this will be extracted as a standalone OSS lib.

#import "FTFontSelectorController.h"
#import "FTFontSelectorController+Private.h"

@implementation FTFontSelectorController

- (instancetype)initWithSelectedFontName:(NSString *)fontName;
{
  FTFontNamesViewController *controller = [FTFontNamesViewController new];
  controller.title = NSLocalizedString(@"Fonts", nil);
  controller.fontNames = FTFontFamilyNames();
  controller.fontSelectorController = self;
  // Only on the iPad and only in the main list of families does the popover
  // dismiss when changing selection. This does NOT mean tapping the disclosure
  // button.
  controller.dismissOnSelection = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

  if ((self = [super initWithRootViewController:controller])) {
    _selectedFontName = fontName;
    _showsDismissButton = YES;
  }
  return self;
}

- (void)changeSelectedFontName:(NSString *)postscriptName;
{
  self.selectedFontName = postscriptName;
  [self.fontDelegate fontSelectorController:self
                  didChangeSelectedFontName:self.selectedFontName];
}

- (void)dismissFontSelector;
{
  [self.fontDelegate fontSelectorControllerShouldBeDismissed:self];
}

// It appears that UINavigationController always returns the size of it's root
// view.
//
// For now override it with how it should be shown on iPad in portrait.
- (CGSize)contentSizeForViewInPopover;
{
  return CGSizeMake(320, 425);
}

@end


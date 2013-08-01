#import <UIKit/UIKit.h>


@class FTFontSelectorController;

@protocol FTFontSelectorControllerDelegate <NSObject>

- (void)fontSelectorController:(FTFontSelectorController *)controller
     didChangeSelectedFontName:(NSString *)postscriptName;

- (void)fontSelectorControllerShouldBeDismissed:(FTFontSelectorController *)controller;

@end


@interface FTFontSelectorController : UINavigationController

@property (weak) id<FTFontSelectorControllerDelegate> fontDelegate;

// This only applies on iPhone. Defaults to YES.
@property (assign) BOOL showsDismissButton;

// The postscript name of the font.
@property (readonly) NSString *selectedFontName;

// The postscript name of the font.
- (instancetype)initWithSelectedFontName:(NSString *)fontName;

@end


#import <Foundation/Foundation.h>

static NSString *FTFontPostscriptName = @"FTFontPostscriptName";
static NSString *FTFontDisplayName = @"FTFontDisplayName";
static NSString *FTFontHasFamilyMembers = @"FTFontHasFamilyMembers";

@interface FTFontSelectorController ()

@property (strong) NSString *selectedFontName;

- (void)changeSelectedFontName:(NSString *)postscriptName;
- (void)dismissFontSelector;

@end


@interface FTFontSelectorController ()

@property (strong) NSString *selectedFontName;

- (void)changeSelectedFontName:(NSString *)postscriptName;
- (void)dismissFontSelector;

@end

//
//  FTFontSelectorController.m
//
//  Created by Eloy Durán on 7/26/13.
//  Copyright (c) 2013 Eloy Durán <eloy.de.enige@gmail.com>. All rights reserved.
//
//  Note: this will be extracted as a standalone OSS lib.

#import "FTFontSelectorController.h"
#import <CoreText/CoreText.h>


static NSString *FTFontPostscriptName = @"FTFontPostscriptName";
static NSString *FTFontDisplayName = @"FTFontDisplayName";
static NSString *FTFontHasFamilyMembers = @"FTFontHasFamilyMembers";


// TODO figure out how to generate this with CoreText if that's more efficient.
static NSArray *
FTFontFamilyNames()
{
  NSArray *names = [UIFont familyNames];
  names = [names sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSMutableArray *families = [NSMutableArray arrayWithCapacity:names.count];
  for (NSString *name in names) {
    NSString *postscriptName = [[UIFont fontWithName:name size:0] fontName];
    NSArray *familyMembers = [UIFont fontNamesForFamilyName:name];
    [families addObject:@{
      FTFontPostscriptName:postscriptName,
      FTFontDisplayName:name,
      FTFontHasFamilyMembers:@(familyMembers.count > 1),
    }];
  }
  return [families copy];
}

// +[UIFont fontNamesForFamilyName:] returns a sort order different from what
// Pages does, but CoreText returns the right order.
static NSArray *
FTFontFamilyMemberNames(NSString *familyName)
{
  CTFontDescriptorRef familyDescriptor;
  CTFontCollectionRef family;
  CFArrayRef descriptors;

  NSString *attribute = (NSString *)kCTFontFamilyNameAttribute;
  familyDescriptor = CTFontDescriptorCreateWithAttributes(
    (__bridge CFDictionaryRef)@{ attribute:familyName }
  );
  family = CTFontCollectionCreateWithFontDescriptors(
    (__bridge CFArrayRef)@[(__bridge id)familyDescriptor],
    NULL
  );
  descriptors = CTFontCollectionCreateMatchingFontDescriptors(family);

  NSMutableArray *familyMemberNames = [NSMutableArray new];
  CFIndex count = CFArrayGetCount(descriptors);
  for (CFIndex i = 0; i < count; i++) {
    CTFontDescriptorRef descriptor;
    CTFontRef font;
    CFStringRef postscriptName, displayName;

    descriptor = (CTFontDescriptorRef)CFArrayGetValueAtIndex(descriptors, i);
    font = CTFontCreateWithFontDescriptor(descriptor, 0, NULL);
    postscriptName = CTFontCopyPostScriptName(font);
    displayName = CTFontCopyLocalizedName(font, kCTFontSubFamilyNameKey, NULL);

    [familyMemberNames addObject:@{
      FTFontPostscriptName:(__bridge id)postscriptName,
      FTFontDisplayName:(__bridge id)displayName,
      FTFontHasFamilyMembers:@(NO),
    }];

    CFRelease(displayName);
    CFRelease(postscriptName);
    CFRelease(font);
  }

  CFRelease(descriptors);
  CFRelease(family);
  CFRelease(familyDescriptor);
  return [familyMemberNames copy];
}


@interface FTFontSelectorController ()
@property (strong) NSString *selectedFontName;
- (void)changeSelectedFontName:(NSString *)postscriptName;
- (void)dismissFontSelector;
@end


@interface FTFontNamesViewController : UITableViewController
@property (strong) NSArray *fontNames;
@property (assign) NSInteger currentSelectedFontIndex;
@property (weak) FTFontSelectorController *fontSelectorController;
@property (assign) BOOL dismissOnSelection;
@end

@implementation FTFontNamesViewController

#pragma mark - UIViewController

- (instancetype)init;
{
  if ((self = [super init])) {
    _dismissOnSelection = NO;
    _currentSelectedFontIndex = -1;
  }
  return self;
}

- (void)viewDidLoad;
{
  [super viewDidLoad];
  [self updateCurrentSelectedFontIndex];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FTFontSelectorController.bundle/ArrowDown"]
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self.fontSelectorController
                                                                           action:@selector(dismissFontSelector)];
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentSelectedFontIndex inSection:0]
                        atScrollPosition:UITableViewScrollPositionMiddle
                                animated:NO];
}

#pragma mark - FTFontNamesViewController

- (void)updateCurrentSelectedFontIndex;
{
  NSString *postscriptName = self.fontSelectorController.selectedFontName;
  NSParameterAssert(postscriptName);

  NSUInteger count = self.fontNames.count;
  for (NSUInteger index = 0; index < count; index++) {
    NSDictionary *name = self.fontNames[index];
    if ([name[FTFontPostscriptName] isEqualToString:postscriptName]) {
      self.currentSelectedFontIndex = index;
      return;
    } else if ([name[FTFontHasFamilyMembers] boolValue]) {
      NSString *familyName = [UIFont fontWithName:name[FTFontPostscriptName] size:0].familyName;
      NSArray *familyMembers = [UIFont fontNamesForFamilyName:familyName];
      if ([familyMembers indexOfObject:postscriptName] != NSNotFound) {
        self.currentSelectedFontIndex = index;
        return;
      }
    }
  }
  self.currentSelectedFontIndex = -1;
}

- (NSString *)postscriptNameAtIndexPath:(NSIndexPath *)indexPath;
{
  return self.fontNames[indexPath.row][FTFontPostscriptName];
}

- (NSString *)displayNameAtIndexPath:(NSIndexPath *)indexPath;
{
  return self.fontNames[indexPath.row][FTFontDisplayName];
}

- (BOOL)hasFamilyMembersAtIndexPath:(NSIndexPath *)indexPath;
{
  return [self.fontNames[indexPath.row][FTFontHasFamilyMembers] boolValue];
}

- (UIFont *)fontAtIndexPath:(NSIndexPath *)indexPath;
{
  NSString *name = [self postscriptNameAtIndexPath:indexPath];
  return [UIFont fontWithName:name size:21];
}

#pragma mark - UITableView cell selection

- (void)updateCheckMarkOfCell:(UITableViewCell *)cell selected:(BOOL)selected;
{
  if (selected) {
    cell.imageView.image = [UIImage imageNamed:@"FTFontSelectorController.bundle/CheckMark"];
    cell.imageView.highlightedImage = [UIImage imageNamed:@"FTFontSelectorController.bundle/CheckMark-White"];
  } else {
    cell.imageView.image = [UIImage imageNamed:@"FTFontSelectorController.bundle/CheckMark-Clear"];
    cell.imageView.highlightedImage = [UIImage imageNamed:@"FTFontSelectorController.bundle/CheckMark-Clear"];
  }
}

- (void)changeSelectedFontToIndexPath:(NSIndexPath *)selectedIndexPath
                              dismiss:(BOOL)dismiss;
{
  if (selectedIndexPath.row == self.currentSelectedFontIndex) return;

  for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self updateCheckMarkOfCell:cell selected:[indexPath isEqual:selectedIndexPath]];
  }

  self.currentSelectedFontIndex = selectedIndexPath.row;
  NSString *postscriptName = [self postscriptNameAtIndexPath:selectedIndexPath];
  [self.fontSelectorController changeSelectedFontName:postscriptName];
  if (dismiss) [self.fontSelectorController dismissFontSelector];
}

#pragma mark - UITableView data source + delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;
{
  return self.fontNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *cellID = @"fontCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellID];
  }

  [self updateCheckMarkOfCell:cell selected:self.currentSelectedFontIndex == indexPath.row];

  if ([self hasFamilyMembersAtIndexPath:indexPath]) {
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  cell.textLabel.font = [self fontAtIndexPath:indexPath];
  cell.textLabel.text = [self displayNameAtIndexPath:indexPath];

  return cell;
}

- (void)tableView:(UITableView *)tableView
        accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
  [self changeSelectedFontToIndexPath:indexPath dismiss:NO];

  NSString *familyName = [self displayNameAtIndexPath:indexPath];
  FTFontNamesViewController *controller = [FTFontNamesViewController new];
  controller.title = familyName;
  controller.fontNames = FTFontFamilyMemberNames(familyName);
  controller.fontSelectorController = self.fontSelectorController;
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self changeSelectedFontToIndexPath:indexPath dismiss:self.dismissOnSelection];
}

@end


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

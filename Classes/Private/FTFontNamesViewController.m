#import "FTFontNamesViewController.h"
#import "FTFontSelectorController+Private.h"

#import <CoreText/CoreText.h>


static NSString *FTFontPostscriptName = @"FTFontPostscriptName";
static NSString *FTFontDisplayName = @"FTFontDisplayName";
static NSString *FTFontHasFamilyMembers = @"FTFontHasFamilyMembers";


static UIImage *
FTFontImageNamed(NSString *imageName)
{
  NSString *name = @"FTFontSelectorController.bundle";
  name = [name stringByAppendingPathComponent:imageName];
  return [UIImage imageNamed:name];
}

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

- (void)loadView;
{
  self.tableView = [UITableView new];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.view = self.tableView;

  [self updateCurrentSelectedFontIndex];
  [self.tableView reloadData];

  if (self.fontSelectorController.showsDismissButton &&
        UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:FTFontImageNamed(@"ArrowDown")
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self.fontSelectorController
                                                              action:@selector(dismissFontSelector)];
    self.navigationItem.rightBarButtonItem = button;
  }
}

- (void)viewWillAppear:(BOOL)animated;
{
  [super viewWillAppear:animated];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentSelectedFontIndex
                                              inSection:0];
  [self.tableView scrollToRowAtIndexPath:indexPath
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
    cell.imageView.image = FTFontImageNamed(@"CheckMark");
    cell.imageView.highlightedImage = FTFontImageNamed(@"CheckMark-White");
  } else {
    cell.imageView.image = FTFontImageNamed(@"CheckMark-Clear");
    cell.imageView.highlightedImage = FTFontImageNamed(@"CheckMark-Clear");
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

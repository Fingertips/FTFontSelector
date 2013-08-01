//
//  FTViewController.m
//  FTFontSelector Example
//
//  Created by Eloy Durán on 01/08/13.
//  Copyright (c) 2013 Fingertips BV. All rights reserved.
//

#import "FTViewController.h"
#import <FTFontSelector/FTFontSelectorController.h>

#define FONT_SIZE 80

@interface FTViewController () <UIPopoverControllerDelegate, FTFontSelectorControllerDelegate>
@property (strong) UITextView *textView;
@property (strong) UIBarButtonItem *changeFontButton;
@property (strong) UIPopoverController *currentPopoverController;
@property (strong) FTFontSelectorController *fontSelectorController;
@end

@implementation FTViewController

- (void)loadView;
{
  CGRect frame = [[UIScreen mainScreen] applicationFrame];
  self.textView = [[UITextView alloc] initWithFrame:frame];
  self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.textView.textAlignment = NSTextAlignmentCenter;
  self.textView.font = [UIFont systemFontOfSize:FONT_SIZE];
  self.textView.text = @"Ohai, world!";

  self.changeFontButton = [[UIBarButtonItem alloc] initWithTitle:@"Font"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(changeFont:)];

  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 44)];
  toolbar.tintColor = [UIColor lightGrayColor];
  toolbar.translucent = YES;
  toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  toolbar.items = @[self.changeFontButton];
  self.textView.inputAccessoryView = toolbar;

  self.view = self.textView;
}

- (void)viewDidAppear:(BOOL)animated;
{
  [super viewDidAppear:animated];
  [self.textView becomeFirstResponder];
}

- (FTFontSelectorController *)createFontController;
{
  NSString *postscriptfontName = self.textView.font.fontName;
  FTFontSelectorController *controller;
  controller = [[FTFontSelectorController alloc] initWithSelectedFontName:postscriptfontName];
  controller.fontDelegate = self;
  return controller;
}

- (void)changeFont:(id)sender;
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    if (self.currentPopoverController) {
      [self.currentPopoverController dismissPopoverAnimated:YES];
      self.currentPopoverController = nil;
    } else {
      self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:[self createFontController]];
      self.currentPopoverController.delegate = self;
      [self.currentPopoverController presentPopoverFromBarButtonItem:self.changeFontButton
                                            permittedArrowDirections:UIPopoverArrowDirectionDown
                                                            animated:YES];
    }
  } else {
    if (self.textView.inputView == nil) {
      self.fontSelectorController = [self createFontController];
      // self.fontSelectorController.showsDismissButton = NO;

      // self.fontSelectorController.navigationBar.barStyle = UIBarStyleBlack;
      UIColor *cherryBlossomPink = [UIColor colorWithRed:1 green:197.0/255.0 blue:183.0/255.0 alpha:1];
      self.fontSelectorController.navigationBar.tintColor = cherryBlossomPink;

      // HACK: To ensure the toolbar is still shown:
      // 
      // 1. hide the keyboard (which is the text view’s inputView)
      // 2. assign the font selector to the UITextView’s inputView
      // 3. make the text view show the inputView again
      [self.textView resignFirstResponder];
      self.textView.inputView = self.fontSelectorController.view;
      [self.textView becomeFirstResponder];
      // 4. finally do the proper child container dance, but not before
      //    assigning as the inputView, because iOS will complain
      [self addChildViewController:self.fontSelectorController];
      [self.fontSelectorController didMoveToParentViewController:self];
    } else {
      [self dismissInputViews];
      [self.textView becomeFirstResponder];
    }
  }
}

- (void)dismissInputViews;
{
  [self.textView resignFirstResponder];
  if (self.textView.inputView) {
    [self.fontSelectorController willMoveToParentViewController:nil];
    self.textView.inputView = nil;
    [self.fontSelectorController removeFromParentViewController];
    self.fontSelectorController = nil;
  }
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
  self.currentPopoverController = nil;
}

#pragma mark -
#pragma mark FTUIFontSelectorController

- (void)fontSelectorController:(FTFontSelectorController *)controller
     didChangeSelectedFontName:(NSString *)fontName;
{
  self.textView.font = [UIFont fontWithName:fontName size:FONT_SIZE];
}

- (void)fontSelectorControllerShouldBeDismissed:(FTFontSelectorController *)controller;
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self.currentPopoverController dismissPopoverAnimated:YES];
    self.currentPopoverController = nil;
  } else {
    [self dismissInputViews];
  }
}

#pragma mark -
#pragma mark UIViewController rotation events

// Explicitely forward these rotation events to the FTFontSelectorController instance.
//
// This is needed because we add the view to the UITextView’s inputView, which belongs to a
// different window. I.e. this is **not** needed with normal view controller containment.

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;
{
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                          duration:duration];

  if (self.fontSelectorController) {
    [self.fontSelectorController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                                  duration:duration];
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation
                                 duration:duration];

  if (self.fontSelectorController) {
    [self.fontSelectorController willRotateToInterfaceOrientation:toInterfaceOrientation
                                                         duration:duration];
  } else if (self.currentPopoverController) {
    [self.currentPopoverController dismissPopoverAnimated:NO];
  }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  if (self.fontSelectorController) {
    [self.fontSelectorController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  } else if (self.currentPopoverController) {
    [self.currentPopoverController presentPopoverFromBarButtonItem:self.changeFontButton
                                          permittedArrowDirections:UIPopoverArrowDirectionDown
                                                          animated:NO];
  }
}

@end

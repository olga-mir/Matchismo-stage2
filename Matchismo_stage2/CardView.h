//
//  CardView.h
//  Matchismo_stage2
//
//  Created by Olga on 26/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;

@interface CardView : UIView

@property (nonatomic, getter = isFaceUp) BOOL faceUp;

@property (nonatomic) CGFloat faceCardScaleFactor;

@property (strong, nonatomic)NSString *contents;

- (void)setup;
- (void)animateCardFrameChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withDuration:(CGFloat)duration withDelay:(CGFloat)delay;


#define CARD_SELECTION_COMPLETED_NOTIFICATION     @"CardSelectionCompletedNotification"
#define CARD_DESELECTION_COMPLETED_NOTIFICATION   @"CardDeselectionCompletedNotification"
#define CARD_REMOVAL_COMPLETED_NOTIFICATION       @"CardRemovalCompletedNotification"


// Virtual methods
- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)card;
- (CGFloat)cornerRadius;
- (BOOL)getSelectedState;
- (void)toggleSelectedState;

@end

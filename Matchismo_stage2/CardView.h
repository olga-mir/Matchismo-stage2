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

/**
 *  Describes if the card is face up. The card with face up property set to YES must be drawn with its contents presented in graphical way
 */
@property (nonatomic, getter = isFaceUp) BOOL faceUp;

/**
 *  Scale face image (J,K,Q) to draw inside the card
 */
@property (nonatomic) CGFloat faceCardScaleFactor;

/**
 *  Describe (model) card contents
 */
@property (strong, nonatomic)NSString *contents;

/**
 *  Setup graphic properties
 */
- (void)setup;

/**
 *  Animate the change in the frame with required duration and delay
 *
 *  @param fromFrame initial frame for animation
 *  @param toFrame   the final frame
 *  @param duration  animation duration (in sec)
 *  @param delay     delay before starting animation (in sec)
 */
- (void)animateCardFrameChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withDuration:(CGFloat)duration withDelay:(CGFloat)delay;

/**
 *  Notification names strings to enable animation chaining
 *
 */
#define CARD_SELECTION_COMPLETED_NOTIFICATION     @"CardSelectionCompletedNotification"
#define CARD_DESELECTION_COMPLETED_NOTIFICATION   @"CardDeselectionCompletedNotification"


// Virtual methods.
- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)card;
- (CGFloat)cornerRadius;
- (BOOL)getSelectedState;
- (void)toggleSelectedState;

@end

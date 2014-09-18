//
//  SetCardView.h
//  Matchismo_stage2
//
//  Created by Olga on 29/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardView.h"
#import "SetCard.h"

@interface SetCardView : CardView


/**
 *  Selected state of a card. Set cards are always "face Up". Cards that are not dealt from the deck have no view associated with it, so from the View's standpoint the Set card is always face up. The actual state for Set card is either 'selected' or 'not selected'
 */
@property (nonatomic, getter = isSelected) BOOL selected;

/**
 *  Designated initializer
 *
 *  @param frame view's frame
 *  @param card  the model card to be presented by this view object
 *
 *  @return the instantiated object, nil in case of error
 */
- (CardView *)initWithFrame:(CGRect)frame withCard:(SetCard *)card;

+ (CGFloat)getCardAspectRatio;

@end

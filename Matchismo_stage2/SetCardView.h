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

// Set cards are always faceup. (Cards that are not dealt, don't have a View
// associated with it, so from the View stand point the Set card is always faceUp
// However in face up state it can be in selected or not-selected state
@property (nonatomic, getter = isSelected) BOOL selected;

- (CGFloat)getCardAspectRatio;

- (CardView *)initWithFrame:(CGRect)frame withCard:(SetCard *)card;

@end

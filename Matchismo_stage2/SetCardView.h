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

- (CGFloat)getCardAspectRatio;

- (CardView *)initWithFrame:(CGRect)frame withCard:(SetCard *)card;

- (CGFloat)cornerRadius;

@end

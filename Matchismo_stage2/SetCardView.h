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

- (CardView *)initWithFrame:(CGRect)frame withCard:(SetCard *)card;

@end

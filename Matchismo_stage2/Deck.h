//
//  Deck.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject <NSCopying>

- (void)addCard:(Card *) card atTop:(BOOL)atTop;
- (void)addCard:(Card *) card;

- (Card *)drawRandomCard;

- (NSUInteger)remainingCards;


@end

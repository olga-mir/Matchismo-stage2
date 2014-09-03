//
//  Deck.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "Deck.h"

@interface Deck()
@property (strong, nonatomic) NSMutableArray *cards; // of Card
@end

@implementation Deck

- (NSMutableArray *)cards
{
  if (!_cards) _cards = [[NSMutableArray alloc] init];
  return _cards;
}

// add card at index 0
- (void)addCard:(Card *)card atTop:(BOOL)atTop
{
  if (atTop) {
    [self.cards insertObject:card atIndex:0];
  } else {
    [self.cards addObject:card];
  }
}

// add card to the deck, no matter where
- (void)addCard:(Card *)card
{
  [self addCard:card atTop:NO];
}

// Remove random card from the deck
- (Card *)drawRandomCard
{
  Card *randomCard = nil;
  
  if ([self.cards count]) {
    unsigned index = arc4random() % [self.cards count];
    randomCard = self.cards[index];
    [self.cards removeObjectAtIndex:index];
  }
  return randomCard;
}

// return the current number of cards in the deck
- (NSUInteger)remainingCards
{
  return [self.cards count];
}

// clone the deck
- (instancetype)copy
{
  Deck *deckCopy = [[Deck alloc] init];
  for (int i = 0; i < [self.cards count]; i++) {
    Card *cardCopy = [self.cards[i] copy];
    [deckCopy addCard:cardCopy];
  }
  return deckCopy;
}


@end
